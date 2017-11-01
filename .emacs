;; Customized color scheme.
(custom-set-variables
 '(TeX-source-correlate-mode t)
 '(ansi-color-names-vector ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(inhibit-startup-screen t)
 '(org-agenda-files (quote ("~/workspace/notes/org-agenda/todos.org")))
 '(org-agenda-skip-scheduled-if-done t)
 '(org-columns-default-format "%40ITEM(TASKS) %TODO %1PRIORITY %8TAGS %DEADLINE")
 '(org-log-done (quote time))
 '(show-paren-mode t))
(custom-set-faces
 '(default ((t (:inherit nil :stipple nil :background "gray25" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 128 :width normal :foundry "unknown" :family "Ubuntu Mono"))))
 '(error ((t (:foreground "IndianRed1" :weight bold))))
 '(highlight ((t (:background "gray60"))))
 '(org-agenda-date-weekend ((t (:inherit org-agenda-date))) t)
 '(org-agenda-done ((t (:foreground "dark sea green"))))
 '(org-todo ((t (:foreground "IndianRed1" :weight bold))))
 '(org-warning ((t (:foreground "IndianRed2"))))
 '(region ((t (:background "coral")))))


;; org mode custom agendas
(setq org-agenda-custom-commands 
      '(
	("d" "Discuss" tags-todo "DI")
	("P" "Projects" tags-todo "PR")
	("S" "Stuck"
         ((todo "WAITING")
	  (todo "HOLD")))
	("c" "Weekly schedule" agenda ""
         ((org-agenda-ndays 14)
          (org-agenda-repeating-timestamp-show-all t)   
          (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))))
	("Q" "Todays tasks" agenda ""
	 ((org-agenda-view-columns-initially t)
	  (org-agenda-ndays 1)))
        )
)

;; todo settings
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "|" "DONE(d)")
              (sequence "NEXT(n)" "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" ))))

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("HOLD" ("WAITING") ("HOLD" . t))
              (done ("WAITING") ("HOLD"))
              ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
              ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "IndianRed2" :weight bold)
              ("NEXT" :foreground "LightSkyBlue1" :weight bold)
              ("DONE" :foreground "DarkSeaGreen" :weight bold)
              ("WAITING" :foreground "LightSkyBlue2" :weight bold)
              ("HOLD" :foreground "LightYellow2" :weight bold)
              ("CANCELLED" :foreground "DarkSeaGreen" :weight bold)
	      ("NEXT" :foreground "IndianRed1" :weight bold)
              )))

;; MELPA
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))


;; required packages
(setq package-list '(company-irony irony company irony-eldoc irony))

;; activate all packages
(package-initialize)

;; install missing packages
(unless package-archive-contents
  (package-refresh-contents))

(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; Clang-format
(setq clangf-path
      (file-expand-wildcards "/usr/share/emacs/site-lisp/clang-format-*/clang-format.el"))
(if clangf-path
    (progn
      (load (nth 0 clangf-path))
      (global-set-key [C-M-tab] 'clang-format-region)
      ;; hook to use clang-format on save
      (defun clang-format-before-save ()
	(interactive)
	(when (eq major-mode 'c++-mode) (clang-format-buffer)))
      (add-hook 'before-save-hook 'clang-format-before-save))
    (print "Could not find clang-format."))

;; open .h in c++ mode
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; irony mode for c++ autocomplete
;; --> https://github.com/Sarcasm/irony-mode
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;; company-irony
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))
(add-hook 'after-init-hook 'global-company-mode)
(global-set-key [C-tab] 'company-complete)
