;; contracts/piggy-bank.clar
;; STX Piggy Bank
;; - Users can create piggy banks
;; - Deposit STX anytime
;; - Once "smashed", funds are released and bank closes forever

(define-data-var bank-count uint u0)

(define-map banks
    { id: uint }
    {
        owner: principal,
        balance: uint,
        smashed: bool,
    }
)

(define-constant ERR-NOT-OWNER u100)
(define-constant ERR-SMASHED u101)
(define-constant ERR-NOT-SMASHED u102)

;; Create a new piggy bank
(define-public (create-bank)
    (let ((id (+ u1 (var-get bank-count))))
        (begin
            (var-set bank-count id)
            (map-set banks { id: id } {
                owner: tx-sender,
                balance: u0,
                smashed: false,
            })
            (ok id)
        )
    )
)

;; Deposit into piggy bank
(define-public (deposit
        (id uint)
        (amount uint)
    )
    (let ((bank (map-get? banks { id: id })))
        (begin
            (asserts! (is-some bank) (err ERR-NOT-SMASHED))
            (let ((b (unwrap! bank (err ERR-NOT-SMASHED))))
                (asserts! (not (get smashed b)) (err ERR-SMASHED))
                (as-contract (stx-transfer? amount tx-sender (contract-caller)))
                (map-set banks { id: id } {
                    owner: (get owner b),
                    balance: (+ (get balance b) amount),
                    smashed: false,
                })
            )
            (ok true)
        )
    )
)

;; Smash piggy bank (withdraw & close forever)
(define-public (smash (id uint))
    (let ((bank (map-get? banks { id: id })))
        (begin
            (asserts! (is-some bank) (err ERR-NOT-SMASHED))
            (let ((b (unwrap! bank (err ERR-NOT-SMASHED))))
                (asserts! (is-eq tx-sender (get owner b)) (err ERR-NOT-OWNER))
                (asserts! (not (get smashed b)) (err ERR-SMASHED))
                (as-contract (stx-transfer? (get balance b) (contract-caller) (get owner b)))
                (map-set banks { id: id } {
                    owner: (get owner b),
                    balance: u0,
                    smashed: true,
                })
            )
            (ok true)
        )
    )
)

;; --- views ---
(define-read-only (get-bank (id uint))
    (map-get? banks { id: id })
)

(define-read-only (get-count)
    (var-get bank-count)
)