;; Oluwa-Coin (OLC) - Secure fungible token
;; Clarity v3

(define-fungible-token oluwa-coin)

;; ----- Metadata -----
(define-constant TOKEN-NAME "Oluwa-Coin")
(define-constant TOKEN-SYMBOL "OLC")
(define-constant TOKEN-DECIMALS u8)

;; Hard cap to keep supply bounded (adjust as needed)
(define-data-var cap uint u1000000000000)

;; Owner is set once via initialize-owner
(define-data-var owner (optional principal) none)

;; ----- Errors -----
(define-constant ERR-NOT-INITIALIZED u100)
(define-constant ERR-NOT-OWNER u101)
(define-constant ERR-CAP-EXCEEDED u102)

;; ----- Read-only helpers -----
(define-read-only (get-name)
  (ok TOKEN-NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply oluwa-coin))
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance oluwa-coin who))
)

(define-read-only (get-owner)
  (ok (var-get owner))
)

(define-read-only (get-cap)
  (ok (var-get cap))
)

;; ----- Initialization -----
;; Can be called exactly once, by the deployer or any chosen account.
(define-public (initialize-owner)
  (if (is-some (var-get owner))
      (err ERR-NOT-INITIALIZED) ;; already initialized
      (begin
        (var-set owner (some tx-sender))
        (ok true)
      )
  )
)

;; ----- Minting (owner-only, supply-capped) -----
(define-private (assert-owner (caller principal))
  (match (var-get owner)
    owner-principal (if (is-eq owner-principal caller)
                        (ok true)
                        (err ERR-NOT-OWNER))
    (err ERR-NOT-INITIALIZED)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (let ((auth (assert-owner tx-sender)))
    (if (is-ok auth)
        (let ((new-supply (+ (ft-get-supply oluwa-coin) amount)))
          (if (> new-supply (var-get cap))
              (err ERR-CAP-EXCEEDED)
              (ft-mint? oluwa-coin amount recipient)
          )
        )
        auth
    )
  )
)

;; ----- Transfers -----
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (ft-transfer? oluwa-coin amount sender recipient)
)