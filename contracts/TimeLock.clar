;; contracts/timelock.clar
;; TimeLock - Delayed STX Vault 

(define-map locks
  principal
  { amount: uint, unlock-block: uint }
)

;;  Lock STX until a future block
(define-public (lock (amount uint) (unlock-block uint))
  (begin
    (asserts! (> amount u0) (err u102))
    (asserts! (> unlock-block block-height) (err u103))
    (asserts! (is-none (map-get? locks tx-sender)) (err u104))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set locks tx-sender { amount: amount, unlock-block: unlock-block })
    (ok amount)
  )
)

;;  Withdraw once unlocked
(define-public (withdraw)
  (let ((record (map-get? locks tx-sender)))
    (match record
      data
      (let (
        (amt (get amount data))
        (ub (get unlock-block data))
      )
        (asserts! (>= block-height ub) (err u100))
        (map-delete locks tx-sender)
        (try! (as-contract (stx-transfer? amt tx-sender tx-sender)))
        (ok amt)
      )
      (err u101) ;; no lock found
    )
  )
)

;; --- Views ---
(define-read-only (get-lock (user principal)) (map-get? locks user))
(define-read-only (get-current-block) block-height)
(define-read-only (get-contract-balance) (stx-get-balance (as-contract tx-sender)))
(define-read-only (get-user-balance (user principal)) (stx-get-balance user))
(define-read-only (get-total-locked) (fold + (map-values locks) u0))