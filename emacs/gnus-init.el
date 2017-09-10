(setq gnus-select-method '(nnimap "imap.gmail.com"
                                  (nnimap-stream tls)
                                  (nnimap-user "lankri.idir@gmail.com"))
      ;; Display the date in the summary line format.
      gnus-summary-line-format "%U%R%z%I%(%[%&user-date;: %-23,23f%]%) %s\n"
      gnus-gcc-mark-as-read t
      gnus-interactive-exit 'quiet
      ;; Display most recent articles first.
      gnus-thread-sort-functions '(gnus-thread-sort-by-number
                                   gnus-thread-sort-by-most-recent-date)
      gnus-large-newsgroup nil)
