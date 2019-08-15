;; -*- mode: emacs-lisp; lexical-binding: t; -*-
;;; vlcrc --- A remote control interface to vlc from Emacs

;;; Summary:
;; Using the rc interface of vlc Emacs can control
;; media playing quite easily.

;; WARN
;; some functionality doesn't work while the stream is paused on vlc
;; versions before 4.0.x. There's no real fix for this aside from
;; moving to a newer version of VLC.

;; WARN
;; if you have an open telnet or netcat connection to the VLC server
;; any outgoing requests from emacs will be blocked until you release
;; it. This means for some commands (such as play), emacs will appear
;; to do nothing, whereas other commands such as get video track list
;; will return nothing because the process took too long to respond.
;;
;; TLDR; You've got an interface to vlc from emacs... USE IT!!!

;; TODO
;; create custom major mode for the client buffer so that you can use
;; it as a shell to directly interface with vlcrc

;; unbound commands:
;; status
;; info
;; key
;; get_title
;;
;; titles & chapter commands

(require 'cl)
(require 'cl-lib)
(require 'bind-key)

;   ____          _                  _
;  / ___|   _ ___| |_ ___  _ __ ___ (_)___  ___
; | |  | | | / __| __/ _ \| '_ ` _ \| / __|/ _ \
; | |__| |_| \__ \ || (_) | | | | | | \__ \  __/
;  \____\__,_|___/\__\___/|_| |_| |_|_|___/\___|
;

(defgroup vlc ()
  "interface to the VideoLAN suite of programs"
  :group 'multimedia)

(defvar vlc-process nil
  "stream/socket connected to VLC server")

(defcustom vlc-program-name "vlc"
  "The program to use for vlc subprocesses"
  :group 'vlc)

(defcustom vlc-server-host "localhost"
  "The host domain tied to the vlc server
vlc-rc uses TCP for connections so you should never
change this variable. This exists in case I one day
figure out how to change the protocol."
  :group 'vlc)

(defcustom vlc-server-port 9313
  ;; first 4 numbers in the md5 sum of 'vlc'
  "The port on host to dedicate to vlc's server"
  :group 'vlc)

(defcustom vlc-bind-server-to-emacs nil
  "whether any opened vlc processes should die with emacs
by default, if the connected VLC server was spawned from
emacs, it should outlive emacs (just as it would if it wasn't
spawned from within emacs). If you'd like VLC to exit alongisde
emacs, set this to true.

You may want to set this to true if your working in a non unix
like environment (such as windows, without cygwin or msys).
because otherwise, no VLC process will be able to start due to
a lacking nohup executeable.

NOTE this'll also enable the warning on exit if the VLC
process isn't killed before exiting."
  :group 'vlc)

(defcustom vlc-client-buffer-name "*vlc*"
  "name of the buffer into which vlc client output will be written.")

(defcustom vlc-response-check-interval 0.1
  "how long to wait between checking for command responses.
vlc/send-message will sometimes be given a callback function
this function will be passed the output from the process
in response to the command. To do so, one must check at
periodic intervals for whether any new data has been written
and once you know there hasn't, you can conclude the output
is complete. This value sets the interval between checks.

Depending on your hardware, setting this to a higher value
may make things more reliable (though will also slow down
response times)."
  :group 'vlc)

(defcustom vlc-supress-warnings nil
  "whether to show warnings on failed commands or not.
goto line 7 of this file and you'll see that vlc doesn't execute
some commands while playback is paused. By default this framework
will throw a warning every time this happens, however if you'd
rather it just displays a message then set this to true."
  :group 'vlc)

(defcustom vlc-start-playback-when-needed-for-command t
  "unpause for commands that require VLC to be unpaused.
As stated previously, this is only an issue in VLC 3 and once
4 becomes the standard I'll hopefully be able to deprecate this
option. In the meantime, if this is nil, depending on the value
of `vlc-supress-warnings' a warning or error will be thrown when
the desired command can't be executed.

WARN vlc will glitch out if you add the same file that currently
     playing while vlc is paused. Probably because you start the
     the file, reopen its own fd and then pause the file really
     quickly. That cannot be good for buffering"
  :group 'vlc)





;  ____
; |  _ \ _ __ ___   ___ ___  ___ ___
; | |_) | '__/ _ \ / __/ _ \/ __/ __|
; |  __/| | | (_) | (_|  __/\__ \__ \
; |_|   |_|  \___/ \___\___||___/___/
;
;  __  __                                                   _
; |  \/  | __ _ _ __   __ _  __ _  ___ _ __ ___   ___ _ __ | |_
; | |\/| |/ _` | '_ \ / _` |/ _` |/ _ \ '_ ` _ \ / _ \ '_ \| __|
; | |  | | (_| | | | | (_| | (_| |  __/ | | | | |  __/ | | | |_
; |_|  |_|\__,_|_| |_|\__,_|\__, |\___|_| |_| |_|\___|_| |_|\__|
;                           |___/

(defun vlc-process ()
  "returns the network process connected to a VLC server.
if it doesn't exist, create it. If there's no VLC server
to connect to, make that first and then connect to it.

Only call this function if you explicitly need an open VLC
connection, one will be made for you regardless."
  (if vlc-process
    ;; if a connection to VLC already exists
    (unless (process-live-p vlc-process)
      (message "vlc socket dead, creating new connection")
      (vlc/create-new-vlc-client))
    (vlc/create-new-vlc-client))

  vlc-process)

(defun vlc/create-new-vlc-server ()
  "creates a new VLC instance with remote control connection at host"
  ;; TODO escape args
  ;; TODO prompt for host and port
  (let* ((host (format "%s:%d" vlc-server-host vlc-server-port))
         (process-args `(,vlc-program-name "--extraintf" "rc" "--rc-host" ,host)))
    (if (not vlc-bind-server-to-emacs)
        (setq process-args (append `("nohup") process-args)))

    (let ((process (apply 'start-process "vlc-server" nil process-args)))
      ;; process won't die with emacs, so ignore it
      (and (not vlc-bind-server-to-emacs)
           (set-process-query-on-exit-flag process nil)))))

(defun vlc/create-new-vlc-client (&optional dont-open-server-on-no-socket)
  (vlc/kill-process nil t) ; kill existing client socket
  ;; WARN prefix should be nil or you'll encounter infinite recursion
  ;;      due to interactive prefix functionality.

  (let ((p-args `("vlc" ,vlc-client-buffer-name ,vlc-server-host ,vlc-server-port)))
    (setq vlc-process
          (condition-case nil
              ;; connection refused, server inactive
              (apply 'open-network-stream p-args)
            (error
             (when (not dont-open-server-on-no-socket)
               ;; if caller allows the creation of a new vlc instance
               (message (format "no vlc instance at %s:%d found" vlc-server-host vlc-server-port))
               (vlc/create-new-vlc-server)
               (apply 'open-network-stream p-args))))))
  (and vlc-process (set-process-query-on-exit-flag vlc-process nil)))





;  ____  _                 _           _        _   _
; / ___|(_)_ __ ___  _ __ | | ___     / \   ___| |_(_) ___  _ __  ___
; \___ \| | '_ ` _ \| '_ \| |/ _ \   / _ \ / __| __| |/ _ \| '_ \/ __|
;  ___) | | | | | | | |_) | |  __/  / ___ \ (__| |_| | (_) | | | \__ \
; |____/|_|_| |_| |_| .__/|_|\___| /_/   \_\___|\__|_|\___/|_| |_|___/
;                   |_|

;; WARN simple does not mean `simple'. in this case simple is an allusion
;; to repetitive, I.E. a lot of the following commands used related logic
;; and thus I abstracted the complicated stuff into macros.

(cl-defmacro vlc/-re-attempt-on-pause-cancel (failed-handler &rest body)
  `(progn
    ,@body
    (when (re-search-forward "^\\(?:Press\\|Type\\) '?pause'? to continue.$" nil t)
      (if vlc-start-playback-when-needed-for-command
          (progn
            (vlc/toggle-play)
            ,@body
            (vlc/toggle-play))
        (if vlc-supress-warnings
            (message "unable to execute command due to playback being paused.")
          (display-warning '(vlc) "unable to execute command due to playback being paused."))))))

(defun vlc/send-message (msg &optional callback)
  (with-current-buffer (get-buffer-create vlc-client-buffer-name)
    (if (not callback)
        (process-send-string (vlc-process) (concat msg "\n"))
      (let (response-start response-end cancelled ended result)
        (vlc/-re-attempt-on-pause-cancel
         ;;begin on-fail-handler
         (setq cancelled t)
         ;;close on-fail-handler

         (setq response-start (buffer-end 1))
         (setq response-end   response-start)
         (setq cancelled nil
               ended     nil)

         (process-send-string (vlc-process) (concat msg "\n"))
         ;; keep waiting until response fully read
         (while (and (not cancelled)
                     (not ended))
           (if (not (sit-for vlc-response-check-interval))
               (setq cancelled t)
             (if (eql response-end
                     (buffer-end 1))
                 (setq ended t)
               (setq response-end (buffer-end 1)))))

         (goto-char response-start))
        (if (and (not cancelled)
                 (functionp callback))
            (save-restriction
              (narrow-to-region response-start response-end)
              (setq result (funcall callback))))
        (goto-char response-end)
        (message "process start/end is %d/%d" response-start response-end)
        result))))

(defun vlc/start-process (&optional prefix)
  "starts (or connects to) a vlc server and creates a client for it.
pass a prefix arg if you want to kill and then reopen your vlc
process. Otherwise, this function will basically do nothing if
the server already exists."
  (interactive "P")
  (if (and prefix (vlc/alive-p))
    (call-interactively 'vlc/kill-process))
  (vlc-process))

(defun vlc/kill-process (&optional prefix silent)
  "kills the local connection to the vlc server
pass a prefix arg if you also want to kill the server
alongside the connection to it.

If the connection is dead and a prefix arg is given
a new connection will be made and then both the window
and the connection will be killed."
  (interactive "P")
  (if (and prefix (or vlc-process (not (vlc/create-new-vlc-client t))))
      ;; with prefix, if an open vlc server does exist, kill it
      ;; and in doing so also kill the socket connection to it.
      (vlc/send-message "quit")
    (when (vlc/alive-p)
      (vlc/send-message "logout")))

  (setq vlc-process nil)
  (unless silent (message (concat "terminated vlc connection"
                                  (if prefix " & vlc server")))))

(defmacro vlc/defun-send-message-command (command-name message &optional docstring &key let-prefix-multiply-message-count)
  "macro to define commands which send a message to the vlc server
the command-name should be the part of the command following
`vlc/' and the message should be a string which can be sent
as is."
  `(defun ,(intern (concat "vlc/" (symbol-name command-name))) (&optional prefix)
     ,docstring
     (interactive "P")
     (if (and ,let-prefix-multiply-message-count
              prefix)
         (vlc/send-message (loop repeat (abs prefix) concat (concat ,message "\n")))
       (vlc/send-message ,message))))

(vlc/defun-send-message-command play "play"
  "play the current stream. WARN This doesn't unpause.")

(vlc/defun-send-message-command stop "stop"
  "stops the current stream. same as pressing the square button.")

(vlc/defun-send-message-command next "next"
  "move to the next item queued in your main playlist.")

(vlc/defun-send-message-command previous "prev"
  "move to the last item queued in your main playlist.")

(vlc/defun-send-message-command clear "clear"
  "clear all the items in your current playlist and stop.")

(vlc/defun-send-message-command pause "pause"
  "toggles the pause status of the current stream")

(defalias 'vlc/toggle-play 'vlc/pause) ;; play should do this :(

(vlc/defun-send-message-command fast-forward "fastforward"
  "set playback speed to maximum rate.")

(vlc/defun-send-message-command rewind "rewind"
  "set playback speed to minimum rate."
  :let-prefix-multiply-message-count t)

(vlc/defun-send-message-command increase-speed "faster"
  "increase speed of current stream"
  :let-prefix-multiply-message-count t)

(vlc/defun-send-message-command decrease-speed "slower"
  "decrease speed of current stream"
  :let-prefix-multiply-message-count t)

(vlc/defun-send-message-command reset-speed "normal"
  "reset the speed of the current stream to its default.")

(vlc/defun-send-message-command frame-by-frame "frame"
  "play current stream frame by frame")

(vlc/defun-send-message-command screenshot "snapshot"
  "take a video snapshot and store to the default directory.")

(defmacro vlc/defun-on-off-toggler-command (command-name message)
  "a macro used to define vlc commands that set some value to on, off or toggle them.
The semantic approach behind of these intended actions should be the same.
a message of just `message' should toggle the value between it's on and off
state. A value of \"`message' on\" should set the state to its truthy value
and a value of \"`message' off\" should set it to its falsy value."
  `(defun ,(intern (concat "vlc/toggle-" (symbol-name command-name))) (&optional prefix)
     ,(format "toggles the `%s' status in the current VLC stream
an optional prefix arg can be specified to explicitly set this state.
A prefix arg of value >0 will set the status to on. A prefix arg with
a value <0 will set the status to off. Any other will toggle it." (symbol-name command-name))
     (interactive "P")
     (let ((message (if (and (numberp prefix)
                             (not (zerop prefix)))
                       (if (> prefix 0)
                           (concat ,message " on")
                         (concat ,message " off"))
                      ,message)))
       (vlc/send-message message))))

(vlc/defun-on-off-toggler-command repeat "repeat")
(vlc/defun-on-off-toggler-command loop "loop")
(vlc/defun-on-off-toggler-command shuffle "random")
(vlc/defun-on-off-toggler-command fullscreen "f")

(defmacro vlc/defun-send-file-command (command-name message &optional docstring)
  `(defun ,(intern (concat "vlc/" (symbol-name command-name))) (&optional filename)
     ,docstring
     (interactive "fmedia: ")

     (if (eq system-type 'windows-nt)
         ;; for some reason VLC doesn't like / on windows :P
         (setq filename (subst-char-in-string ?/ ?\\ filename)))

     (vlc/send-message (concat ,message " " filename) t)))

(vlc/defun-send-file-command add-file "add"
  "prompts for a file and then plays it with VLC.")

(vlc/defun-send-file-command enqueue-file "enqueue"
  "prompts for a file and adds it to the current playlist")

(cl-defmacro vlc/defun-choose-item-from-list (command-name message match-regex
                                              &optional &key get-list-docstring
                                              set-value-docstring values-to-string
                                              allow-empty)
  "A macro to define a function which lets you set an item from a list of vlcrc options
This macro actually defines two functions. One to parse and retrieve the list of
valid values and another which prompts the user for a choice and sets it.

Parameters
==========
command-name
  symbol used to define the name of the spawned functions. They'll be appended to
  `vlc/get-' and `vlc/set-' respectively, where the former will be callable and
  the latter will not be.
message
  the actual command sent to the vlc-rc process through the client to both list
  all valid entries (when no argument is sent) and set its value (when an arg
  is sent).
match-regex
  regular expression used on the process response to find and extract valid entries.
  the expression should have two capture groups, the first is the argument sent to
  choose that entry, the second is a human readable name.
get-list-docstring
  documentation string for the get-list function
set-value-docstring
  documentation string for the set-list function
values-to-string
  convert the alist tuple response for each entry extracted using the match regex
  to a representable value string for read-completion.
allow-empty
  normally if a `vlc/get-' call doesn't produce any valid entries a warning will
  be issued. Sometimes this may be the desired behaviour, such as subtitles. If
  this value is true then empty lists will be ignored."
  (or values-to-string (setq values-to-string (lambda (tuple) (concat (car tuple) " - " (cdr tuple)))))

  (let* ((command-string (symbol-name command-name))
         (get-list-name (intern (concat "vlc/get-" command-string "-list")))
         (set-value-name (intern (concat "vlc/set-" command-string))))
    `(progn
      (defun ,get-list-name ()
        ,get-list-docstring
        (vlc/send-message ,message #'(lambda ()
                                        (let (aggregate '())
                                          (while (search-forward-regexp ,match-regex nil t)
                                            (setq aggregate (append aggregate `((,(match-string 1) . ,(match-string 2))))))
                                          aggregate))))

      (defun ,set-value-name ()
        ,set-value-docstring
        (interactive)
        (let* ((values (,get-list-name))
              (titles (mapcar #',values-to-string values)))
          (if (eql 0 (length values))
              (if ,allow-empty
                  (message ,(if (stringp allow-empty) allow-empty
                              (concat "unable to set value because no valid fields found for "
                                      command-string)))
                (display-warning '(vlc) "vlc server took too long to respond"))
            (let ((choice (completing-read ,(concat command-string ": ") titles nil t)))
              (when choice
                (let ((choice-id (car (nth (cl-position choice titles :test 'string-equal) values))))
                  (vlc/send-message (concat ,message " " choice-id)))))))))))

(vlc/defun-choose-item-from-list audio-device "adev" "^| \\({[.[:digit:]]+}\\.{[-0-9a-z]+}\\) - \\(.+\\)$"
  :values-to-string cdr
  :get-list-docstring "retrieve a list of all audio devices known to vlc"
  :set-value-docstring "sets the audio device used by the connected vlc process")

(vlc/defun-choose-item-from-list audio-channel "achan" "^| \\([[:digit:]]+\\) - \\(.+\\)$"
  :values-to-string cdr
  :get-list-docstring "retrieve a list of all available audio channels"
  :set-value-docstring "set the audio channel used by the connected vlc process")

(vlc/defun-choose-item-from-list audio-track "atrack" "^| \\(-?[[:digit:]]+\\) - \\(.+\\)$"
  :values-to-string cdr
  :get-list-docstring "retrieve a list of all the audio tracks in the current media stream"
  :set-value-docstring "set the audio track for the current media stream")

(vlc/defun-choose-item-from-list video-track "vtrack" "^| \\(-?[[:digit:]]+\\) - \\(.+\\)$"
  :values-to-string cdr
  :get-list-docstring "get a list of all the available video tracks for the current media stream"
  :set-value-docstring "set the video track for the current vlc media stream")

;; FIXME vlc shows '' as an option to reset to default aspect ratio but it doesn't seem to be implemented.
;; NOTE  a quick fix would be to simply change the regex so that entry isn't detected.

(vlc/defun-choose-item-from-list aspect-ratio "vratio" "^| \\(\\(?:[[:digit:]]+:[[:digit:]]+\\)?\\) - \\(.+\\)$"
  :values-to-string cdr
  :get-list-docstring "return a list of all the aspect ratios VLC can use"
  :set-value-docstring "set the video/aspect ratio for the current vlc media stream")

(vlc/defun-choose-item-from-list video-crop "vcrop" "^| \\(\\(?:[[:digit:]]+:[[:digit:]]+\\)?\\) - \\(.+\\)$"
  :values-to-string cdr
  :get-list-docstring "return a list of all the crops VLC supports"
  :set-value-docstring "set the video crop for the current vlc media stream")

(vlc/defun-choose-item-from-list video-zoom "vzoom" "^| \\([[:digit:]]+\\.[[:digit:]]+\\)? - \\(.+\\)$"
  :get-list-docstring "return a list of all the zoom values vlc supports"
  :set-value-docstring "set the zoom value for the current vlc media streem")

(vlc/defun-choose-item-from-list subtitle-track "strack" "^| \\(-?[[:digit:]]+\\)? - \\(.+\\)$"
  :values-to-string cdr
  :allow-empty "current media item doesn't have any associated subtitle tracks"
  :get-list-docstring "return all the subtitle tracks in the current vlc media stream"
  :set-value-docstring "set the subtitile track used by the current vlc media stream")

(defmacro vlc/defun-parse-single-value-from-command (command-name message regexp &optional converter)
  `(defun ,(intern (concat "vlc/get-" (symbol-name command-name))) ()
     (vlc/send-message ,message #'(lambda ()
                                    (when (search-forward-regexp ,regexp nil t)
                                      (let ((value (buffer-substring (line-beginning-position)
                                                                     (line-end-position))))
                                        (and ,converter
                                             (setq value (funcall ,converter value)))
                                        value))))))

(vlc/defun-parse-single-value-from-command stream-time "get_time" "^[[:digit:]]+$" #'cl-parse-integer)
(vlc/defun-parse-single-value-from-command stream-length "get_length" "^[[:digit:]]+$" #'cl-parse-integer)





;   ____                      _                _        _   _
;  / ___|___  _ __ ___  _ __ | | _____  __    / \   ___| |_(_) ___  _ __  ___
; | |   / _ \| '_ ` _ \| '_ \| |/ _ \ \/ /   / _ \ / __| __| |/ _ \| '_ \/ __|
; | |__| (_) | | | | | | |_) | |  __/>  <   / ___ \ (__| |_| | (_) | | | \__ \
;  \____\___/|_| |_| |_| .__/|_|\___/_/\_\ /_/   \_\___|\__|_|\___/|_| |_|___/
;                      |_|

(defun vlc/print-help ()
  (interactive)
  (vlc/send-message "help" #'(lambda () (message (buffer-string)))))

(defun vlc/print-stats ()
  (interactive)
  ;; TODO convert to hash, return a meaningful value
  (vlc/send-message "stats" #'(lambda () (message (buffer-string)))))

(defun vlc/volume-ctrl (prefix)
  "manage the volume of the VLC window.
This function sets the volume displayed. use prefix args to increase
volume by prefix steps. supply an empty prefix arg and be prompted for
an exact volume value."
  (interactive "P")
  (if (consp prefix)
      (let ((volume-value (read-number "volume-value: " 0)))
        (and (< volume-value 0)
             (error (format "cannot set vlc volume to negative value: %03d" volume-value)))
        (vlc/send-message (format "volume %d" volume-value) t))
    (unless prefix
      (setq prefix (read-number "volume-prefix: " 1)))
    (let ((command (if (< prefix 0) "voldown" "volup")))
      (vlc/send-message (concat command " " (int-to-string (abs prefix))) t))))

(defun vlc/playlist ()
  "get a list of all the media items in VLCs main playlist"
    (vlc/send-message "playlist" '(lambda ()
                                    (save-excursion
                                      (save-restriction
                                        (let ((playlist-items '()))
                                          (let ((start (point)))
                                            (search-forward-regexp "^|- Media Library$")
                                            (narrow-to-region start (- (line-beginning-position) 1))
                                            (goto-char start)
                                            ;; TODO fix regexp only works for videos that're minutes long (not hours)
                                            (while (search-forward-regexp "^|  - \\(.+\\)\\(?: \\(([[:digit:]]+:[[:digit:]]+)\\)\\)?$" nil t)
                                              (setq playlist-items (append playlist-items `((,(match-string 1) . ,(match-string 2)))))))
                                          playlist-items))))))

(defun vlc/goto-playlist-item ()
  "prompt and then goto an item in your current playlist"
  (interactive)
  (let* ((items (mapcar #'car (vlc/playlist)))
         (choice (completing-read "title: " items nil t)))
    ;; TODO  check current media entry isn't new entry
    ;; FIXME check if no entries in playlist first
    (when choice
      (let ((choice-index (cl-position choice items :test 'string-equal)))
        (vlc/send-message (concat "goto " (number-to-string (+ 1 choice-index))) t)))))

(defun vlc/set-stream-position (&optional prefix)
  "set the timestamp for the current stream in seconds
if a numerical prefix is given then the stream position will
be set to it. Otherwise the user will be prompted for a value.
Valid inputs include a number (set the position to that value)
a percentage (in proportion to the size of the entire input
stream) or one of the diplayed autocomplete suggestions."
  (interactive "P")
  ;; FIXME check if no stream is currently playing
  (let ((stream-time (vlc/get-stream-time))
        (stream-length (vlc/get-stream-length)))
    (when (or (not prefix)
              (consp prefix))
      (let ((choice (s-trim (completing-read "location: " '("START"
                                                            "END"
                                                            "MIDDLE")))))
        (setq prefix (pcase choice
                       ;; TODO allow jumping to chapters
                       ("START"  0)
                       ("MIDDLE" (floor (/ stream-length 2.00)))
                       ("END"    stream-length)
                       (_
                        (and (not (string-match-p "^[-+]?\\([[:digit:]]+\\.?\\(?:[[:digit:]]+\\)?\\)\\(%?\\)$"
                                                   choice))
                             (error "choice is not a numerical value"))
                        (setq choice-num (abs (string-to-number choice)))
                        (if (string-equal (substring choice -1)
                                          "%")
                            (setq choice-num (ceiling (* stream-length (/ choice-num 100.0)))))

                        choice-num)))))
    (and (> prefix stream-length)
         (error "cannot set position to outside the bounds of the stream (%03d, %03d) -> %03d"
                stream-time stream-length prefix))
    (vlc/send-message (concat "seek " (number-to-string prefix)) t)))





;  __  __ _
; |  \/  (_)___  ___
; | |\/| | / __|/ __|
; | |  | | \__ \ (__
; |_|  |_|_|___/\___|
;

(defun vlc ()
  "prompts user for a vlc command and then executes it interactively "
  (interactive)
  (let* ((command-list '("start"
                         "kill"
                         "quit"
                         "exit"
                         "pause"
                         "play"
                         "toggle-play"
                         "enqueu"
                         "clear-playlist"))
         (choice (completing-read "command: " command-list nil t)))
    (setq invoked-process (pcase choice
                            ("start"          'vlc/start-process)
                            ("kill"           'vlc/kill-process)
                            ("pause"          'vlc/pause)
                            ("play"           'vlc/play)
                            ("toggle-play"    'vlc/toggle-play)
                            ("enqueue"        'vlc/enqueu-file)
                            ("clear-playlist" 'vlc/clear-playlist)
                            (_ (error (format "unknown vlc command: %s" choice)))))
    (call-interactively invoked-process)))

(defun vlc/alive-p ()
  (and vlc-process
       (process-live-p vlc-process)))

(defun vlc/show-vlc-buffer ()
  (interactive)
  (display-buffer (get-buffer vlc-client-buffer-name) 'display-buffer-pop-up-window))






;  _____      _                        _
; | ____|_  _| |_ ___ _ __ _ __   __ _| |
; |  _| \ \/ / __/ _ \ '__| '_ \ / _` | |
; | |___ >  <| ||  __/ |  | | | | (_| | |
; |_____/_/\_\\__\___|_|  |_| |_|\__,_|_|
;
;  ___       _                       _   _
; |_ _|_ __ | |_ ___  __ _ _ __ __ _| |_(_) ___  _ __
;  | || '_ \| __/ _ \/ _` | '__/ _` | __| |/ _ \| '_ \
;  | || | | | ||  __/ (_| | | | (_| | |_| | (_) | | | |
; |___|_| |_|\__\___|\__, |_|  \__,_|\__|_|\___/|_| |_|
;                    |___/
;

;; TODO support mark file usage
(defun vlc/dired-add-file ()
  (interactive)
  (vlc/add-file (dired-get-filename)))

(defun vlc/dired-enqueue-file ()
  (interactive)
  (vlc/enqueue-file (dired-get-filename)))





;  _  __          _     _           _ _
; | |/ /___ _   _| |__ (_)_ __   __| (_)_ __   __ _ ___
; | ' // _ \ | | | '_ \| | '_ \ / _` | | '_ \ / _` / __|
; | . \  __/ |_| | |_) | | | | | (_| | | | | | (_| \__ \
; |_|\_\___|\__, |_.__/|_|_| |_|\__,_|_|_| |_|\__, |___/
;           |___/                             |___/

(setq vlc-rc-map (make-sparse-keymap))

(bind-keys :map vlc-rc-map
           ("." . vlc)
           ("c" . vlc)
           ("m" . vlc/send-message)
           ("?" . vlc/print-help)
           ("SPC" . vlc/toggle-play)
           ("RET" . vlc/play)
           ("DEL" . vlc/stop)
           ("C-SPC" . vlc/toggle-fullscreen)

           ;; process control
           ("b" . vlc/start-process)
           ("k" . vlc/kill-process)

           ;; find-file
           ("f" . vlc/add-file)
           ("q" . vlc/enqueue-file)
           ("c" . vlc/clear)

           ;; misc runtime
           ("p" . vlc/previous)
           ("n" . vlc/next)
           ("|" . vlc/screenshot)
           ("g" . vlc/show-vlc-buffer)
           ("v" . vlc/volume-ctrl)
           ("'" . vlc/set-stream-position)

           ;; speed controls
           ("C-+" . vlc/fast-forward)
           ("+"   . vlc/increase-speed)
           ("="   . vlc/reset-speed)
           ("-"   . vlc/decrease-speed)
           ("C--" . vlc/rewind)
           ("o"   . vlc/frame-by-frame)
           ("m"   . vlc/goto-playlist-item)

           :prefix "t"
           :prefix-map vlcrc-toggle-map
           :menu-name "toggle"
           ("l" . vlc/toggle-loop)
           ("r" . vlc/toggle-repeat)
           ("s" . vlc/toggle-shuffle)
           ("f" . vlc/toggle-fullscreen)
           :prefix "s"
           :prefix-map vlcrc-set-map
           :menu-name "set"
           ("d" . vlc/set-audio-device)
           ("c" . vlc/set-audio-channel)
           ("a" . vlc/set-audio-track)
           ("r" . vlc/set-aspect-ratio)
           ("c" . vlc/set-video-crop)
           ("z" . vlc/set-video-zoom)
           ("s" . vlc/set-subtitle-track))

(provide 'vlc-rc)
