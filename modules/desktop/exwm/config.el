;;; desktop/exwm/config.el -*- lexical-binding: t; -*-
(use-package! exwm
  :config
  (setq exwm-workspace-number 6))

(server-start)

(defun evertedsphere/exwm-rename-buffer-to-title ()
  (exwm-workspace-rename-buffer (format "%s - %s" exwm-class-name exwm-title)))

(add-hook 'exwm-update-title-hook 'evertedsphere/exwm-rename-buffer-to-title)

(add-hook 'exwm-update-class-hook
          (defun my-exwm-update-class-hook ()
            (unless (or (string-prefix-p "sun-awt-X11-" exwm-instance-name)
                        (string= "gimp" exwm-instance-name)
                        (string= "Firefox" exwm-class-name))
              (exwm-workspace-rename-buffer exwm-class-name))))

(add-hook 'exwm-update-title-hook
          (defun my-exwm-update-title-hook ()
            (cond ((or (not exwm-instance-name)
                       (string-prefix-p "sun-awt-X11-" exwm-instance-name)
                       (string= "gimp" exwm-instance-name)
                       (string= "Firefox" exwm-class-name))
                   (exwm-workspace-rename-buffer exwm-title)))))

(setq exwm-workspace-show-all-buffers t
      exwm-layout-show-all-buffers t)

(push ?\s-  exwm-input-prefix-keys)
(push ?\M-  exwm-input-prefix-keys)

(display-battery-mode 1)
(display-time-mode 1)

(defun evertedsphere/launch (command)
  (interactive (list (read-shell-command "Launch: ")))
  (start-process-shell-command command nil command))

(defun evertedsphere/screen-to-clipboard ()
  (interactive)
  (shell-command
   (concat "bash -c 'FILENAME=$(date +'%Y-%m-%d-%H:%M:%S').png && maim -s $FILENAME"
           " && xclip $FILENAME -selection clipboard "
           "-t image/png &> /dev/null && rm $FILENAME'"))
  (message "Added to clipboard."))

(defun evertedsphere/switch-to-last-buffer ()
  "Switch to last open buffer in current window."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(when (executable-find "i3lock")
  (defun evertedsphere/i3lock ()
    (interactive)
    (shell-command "i3lock -c '#2D3748'")
    (kill-buffer "*Shell Command Output*"))
  (exwm-input-set-key (kbd "s-<f2>") #'evertedsphere/i3lock))

(when (executable-find "pactl")
  (defun evertedsphere/pactl-dec-volume ()
    (interactive)
    (shell-command "pactl set-sink-volume @DEFAULT_SINK@ -5%")
    (kill-buffer "*Shell Command Output*"))
  (defun evertedsphere/pactl-inc-volume ()
    (interactive)
    (shell-command "pactl set-sink-volume @DEFAULT_SINK@ +5%")
    (kill-buffer "*Shell Command Output*"))
  (exwm-input-set-key (kbd "S-<f11>") #'evertedsphere/pactl-dec-volume)
  (exwm-input-set-key (kbd "S-<f12>") #'evertedsphere/pactl-inc-volume))


(exwm-input-set-key (kbd "s-r") #'exwm-reset)
(exwm-input-set-key (kbd "s-d") #'counsel-linux-app)
(exwm-input-set-key (kbd "s-p") #'password-store-copy)
(exwm-input-set-key (kbd "C-x t") #'vterm)
(exwm-input-set-key (kbd "s-t a") #'evertedsphere/switch-to-agenda)
;; (exwm-input-set-key (kbd "s-t m") #'notmuch)
(exwm-input-set-key (kbd "s-c") #'evertedsphere/org-inbox-capture)
(exwm-input-set-key (kbd "s-f") #'counsel-find-file)
(exwm-input-set-key (kbd "s-<f12>") #'counsel-locate)
(exwm-input-set-key (kbd "s-<tab>") #'evertedsphere/switch-to-last-buffer)
(exwm-input-set-key (kbd "<print>") #'evertedsphere/screen-to-clipboard)

(mapc (lambda (i)
          (exwm-input-set-key (kbd (format "s-%d" i))
                              `(lambda ()
                                 (interactive)
                                 (exwm-workspace-switch-create ,i))))
      (number-sequence 0 9))

(add-hook 'exwm-manage-finish-hook
          (lambda ()
            (when (and exwm-class-name
                       (string= exwm-class-name "kitty"))
              (exwm-input-set-local-simulation-keys '(([?\C-c ?\C-c] . ?\C-c))))))

(setq exwm-input-simulation-keys
      '(
        ;; movement
        ;; ([?\s-h] . [left])
        ;; ([?\s-l] . [right])
        ;; ([?\s-k] . [up])
        ;; ([?\s-j] . [down])
        ([?\C-\s-h] . [left])
        ([?\C-\s-l] . [right])
        ([?\C-\s-k] . [up])
        ([?\C-\s-j] . [down])
        ([?\C-a] . [?\C-a])
        ;; ([?\C-e] . [end])
        ;; ([?\M-v] . [prior])
        ;; ([?\C-v] . [next])
        ;; ([?\C-d] . [delete])
        ([?\C-k] . [S-end delete])
        ;; cut/paste.
        ([?\C-x ?\C-x] . [?\C-x])
        ([?\C-\S-c] . [?\C-c])
        ([?\C-\S-v] . [?\C-v])
        ;; search
        ([?\C-s] . [?\C-s])
        ([?\C-\s-s] . [?\C-f])))


(when (executable-find "brightnessctl")
  (defun evertedsphere/return-brightness-percentage ()
    (interactive)
    (string-to-number (shell-command-to-string "brightnessctl get")))
  (defun evertedsphere/brightness-up ()
    (interactive)
    (shell-command "brightnessctl set 100+")
    (message "Screen Brightness: %s" (evertedsphere/return-brightness-percentage))
    (kill-buffer "*Shell Command Output*"))
  (defun evertedsphere/brightness-down ()
    (interactive)
    (shell-command "brightnessctl set 100-")
    (message "Screen Brightness: %s" (evertedsphere/return-brightness-percentage))
    (kill-buffer "*Shell Command Output*"))
  (exwm-input-set-key (kbd "<XF86MonBrightnessDown>") #'evertedsphere/brightness-down)
  (exwm-input-set-key (kbd "<XF86MonBrightnessUp>") #'evertedsphere/brightness-up))

(define-ibuffer-column exwm-class (:name "Class")
  (if (bound-and-true-p exwm-class-name)
      exwm-class-name
    ""))
(define-ibuffer-column exwm-instance (:name "Instance")
  (if (bound-and-true-p exwm-instance-name)
      exwm-instance-name
    ""))
(define-ibuffer-column exwm-urgent (:name "U")
  (if (bound-and-true-p exwm--hints-urgency)
      "U"
    " "))

(defun evertedsphere/exwm-ibuffer (&optional other-window)
  (interactive "P")
  (let ((name (buffer-name)))
    (ibuffer other-window
             "*exwm-ibuffer*"
             '((mode . exwm-mode))
             nil nil nil
             '((mark exwm-urgent
                     " "
                     (name 64 64 :left :elide)
                     " "
                     (exwm-class 20 -1 :left)
                     " "
                     (exwm-instance 10 -1 :left))))
    (ignore-errors (ibuffer-jump-to-buffer name))))

(exwm-input-set-key (kbd "s-b") #'evertedsphere/exwm-ibuffer)

(exwm-input-set-key (kbd "s-k") 'windmove-up)
(exwm-input-set-key (kbd "s-j") 'windmove-down)
(exwm-input-set-key (kbd "s-h") 'windmove-right)
(exwm-input-set-key (kbd "s-l") 'windmove-left)

(define-key exwm-mode-map (kbd "C-x 4 0")
  (lambda ()
    (interactive)
    (kill-buffer)
    (delete-window)))

(add-hook 'exwm-manage-finish-hook
          (defun my-exwm-urxvt-simulation-keys ()
            (when exwm-class-name
              (cond
               ((string= exwm-class-name "Firefox")
                (exwm-input-set-local-simulation-keys
                 `(,@exwm-input-simulation-keys
                   ([?\C-w] . [?\C-w]))))))))

;; (when (file-exists-p "/home/evertedsphere/.screenlayout/desktop.sh")
;;   (require 'exwm-randr)
;;   (setq exwm-randr-workspace-monitor-plist '(1 "USB-C-0" 2 "HDMI-0"))
;;   (call-process "bash" nil 0 nil "-c" "/home/evertedsphere/.screenlayout/desktop.sh")
;;   (exwm-randr-enable))

(use-package! exwm-edit)

(exwm-enable)
