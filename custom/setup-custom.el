(unless (package-installed-p 'req-package)
  (package-install 'req-package))
(unless (package-installed-p 'rtags)
  (package-install 'rtags))
(unless (package-installed-p 'company-rtags)
  (package-install 'company-rtags))
(unless (package-installed-p 'helm-rtags)
  (package-install 'helm-rtags))
(unless (package-installed-p 'flycheck-rtags)
  (package-install 'flycheck-rtags))


(require 'rtags)
(require 'company-rtags)

(setq rtags-completions-enabled t)
(eval-after-load 'company
  '(add-to-list
    'company-backends 'company-rtags))
(setq rtags-autostart-diagnostics t)
(rtags-enable-standard-keybindings)

(require 'helm-rtags)
(setq rtags-use-helm t)

(require 'req-package)

(req-package flycheck
    :config
    (progn
      (global-flycheck-mode)))

(req-package rtags
     :config
     (progn
         (unless (rtags-executable-find "rc") (error "Binary rc is not installed!"))
         (unless (rtags-executable-find "rdm") (error "Binary rdm is not installed!"))

         (define-key c-mode-base-map (kbd "M-.") 'rtags-find-symbol-at-point)
         (define-key c-mode-base-map (kbd "M-,") 'rtags-find-references-at-point)
         (define-key c-mode-base-map (kbd "M-?") 'rtags-display-summary)
         (rtags-enable-standard-keybindings)

         (setq rtags-use-helm t)

         ;; Shutdown rdm when leaving emacs.
         (add-hook 'kill-emacs-hook 'rtags-quit-rdm)
         ))

;; TODO: Has no coloring! How can I get coloring?
(req-package helm-rtags
      :require helm rtags
      :config
      (progn
          (setq rtags-display-result-backend 'helm)
          ))

;; Use rtags for auto-completion.
(req-package company-rtags
             :require company rtags
             :config
             (progn
               (setq rtags-autostart-diagnostics t)
               (rtags-diagnostics)
               (setq rtags-completions-enabled t)
               (push 'company-rtags company-backends)
               ))

;; Live code checking.
(req-package flycheck-rtags
       :require flycheck rtags
       :config
       (progn
           ;; ensure that we use only rtags checking
           ;; https://github.com/Andersbakken/rtags#optional-1
           (defun setup-flycheck-rtags ()
               (flycheck-select-checker 'rtags)
               (setq-local flycheck-highlighting-mode nil) ;; RTags creates more accurate overlays.
               (setq-local flycheck-check-syntax-automatically nil)
               (rtags-set-periodic-reparse-timeout 2.0)  ;; Run flycheck 2 seconds after being idle.
             )
           (add-hook 'c-mode-hook #'setup-flycheck-rtags)
           (add-hook 'c++-mode-hook #'setup-flycheck-rtags)
           ))

(provide 'setup-custom)
