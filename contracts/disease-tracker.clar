;; Animal Registry Contract
;; Core contract for livestock identification and registration

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ANIMAL-NOT-FOUND (err u101))
(define-constant ERR-ANIMAL-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-INPUT (err u103))
(define-constant ERR-NOT-OWNER (err u104))

;; Data Variables
(define-data-var next-animal-id uint u1)

;; Data Maps
(define-map animals
  { animal-id: uint }
  {
    owner: principal,
    species: (string-ascii 50),
    birth-date: uint,
    registration-date: uint,
    status: (string-ascii 20),
    location: (string-ascii 100)
  }
)

(define-map owner-animals
  { owner: principal, animal-id: uint }
  { registered: bool }
)

(define-map animal-count-by-owner
  { owner: principal }
  { count: uint }
)

;; Public Functions

;; Register a new animal
(define-public (register-animal (species (string-ascii 50)) (birth-date uint) (location (string-ascii 100)))
  (let
    (
      (animal-id (var-get next-animal-id))
      (current-block-height block-height)
    )
    (asserts! (> (len species) u0) ERR-INVALID-INPUT)
    (asserts! (> birth-date u0) ERR-INVALID-INPUT)
    (asserts! (<= birth-date current-block-height) ERR-INVALID-INPUT)

    ;; Store animal data
    (map-set animals
      { animal-id: animal-id }
      {
        owner: tx-sender,
        species: species,
        birth-date: birth-date,
        registration-date: current-block-height,
        status: "active",
        location: location
      }
    )

    ;; Update owner mapping
    (map-set owner-animals
      { owner: tx-sender, animal-id: animal-id }
      { registered: true }
    )

    ;; Update owner count
    (let
      (
        (current-count (default-to u0 (get count (map-get? animal-count-by-owner { owner: tx-sender }))))
      )
      (map-set animal-count-by-owner
        { owner: tx-sender }
        { count: (+ current-count u1) }
      )
    )

    ;; Increment next ID
    (var-set next-animal-id (+ animal-id u1))

    (ok animal-id)
  )
)

;; Transfer animal ownership
(define-public (transfer-animal (animal-id uint) (new-owner principal))
  (let
    (
      (animal-data (unwrap! (map-get? animals { animal-id: animal-id }) ERR-ANIMAL-NOT-FOUND))
      (current-owner (get owner animal-data))
    )
    (asserts! (is-eq tx-sender current-owner) ERR-NOT-OWNER)
    (asserts! (not (is-eq current-owner new-owner)) ERR-INVALID-INPUT)

    ;; Update animal owner
    (map-set animals
      { animal-id: animal-id }
      (merge animal-data { owner: new-owner })
    )

    ;; Remove from old owner mapping
    (map-delete owner-animals { owner: current-owner, animal-id: animal-id })

    ;; Add to new owner mapping
    (map-set owner-animals
      { owner: new-owner, animal-id: animal-id }
      { registered: true }
    )

    ;; Update counts
    (let
      (
        (old-owner-count (default-to u0 (get count (map-get? animal-count-by-owner { owner: current-owner }))))
        (new-owner-count (default-to u0 (get count (map-get? animal-count-by-owner { owner: new-owner }))))
      )
      (map-set animal-count-by-owner
        { owner: current-owner }
        { count: (- old-owner-count u1) }
      )
      (map-set animal-count-by-owner
        { owner: new-owner }
        { count: (+ new-owner-count u1) }
      )
    )

    (ok true)
  )
)

;; Update animal status
(define-public (update-animal-status (animal-id uint) (new-status (string-ascii 20)))
  (let
    (
      (animal-data (unwrap! (map-get? animals { animal-id: animal-id }) ERR-ANIMAL-NOT-FOUND))
      (owner (get owner animal-data))
    )
    (asserts! (is-eq tx-sender owner) ERR-NOT-OWNER)
    (asserts! (or (is-eq new-status "active") (is-eq new-status "inactive") (is-eq new-status "deceased")) ERR-INVALID-INPUT)

    (map-set animals
      { animal-id: animal-id }
      (merge animal-data { status: new-status })
    )

    (ok true)
  )
)

;; Update animal location
(define-public (update-animal-location (animal-id uint) (new-location (string-ascii 100)))
  (let
    (
      (animal-data (unwrap! (map-get? animals { animal-id: animal-id }) ERR-ANIMAL-NOT-FOUND))
      (owner (get owner animal-data))
    )
    (asserts! (is-eq tx-sender owner) ERR-NOT-OWNER)
    (asserts! (> (len new-location) u0) ERR-INVALID-INPUT)

    (map-set animals
      { animal-id: animal-id }
      (merge animal-data { location: new-location })
    )

    (ok true)
  )
)

;; Read-only Functions

;; Get animal information
(define-read-only (get-animal (animal-id uint))
  (map-get? animals { animal-id: animal-id })
)

;; Check if animal exists
(define-read-only (animal-exists (animal-id uint))
  (is-some (map-get? animals { animal-id: animal-id }))
)

;; Get animal owner
(define-read-only (get-animal-owner (animal-id uint))
  (match (map-get? animals { animal-id: animal-id })
    animal-data (some (get owner animal-data))
    none
  )
)

;; Check if user owns animal
(define-read-only (is-animal-owner (animal-id uint) (user principal))
  (match (map-get? animals { animal-id: animal-id })
    animal-data (is-eq (get owner animal-data) user)
    false
  )
)

;; Get animal count for owner
(define-read-only (get-owner-animal-count (owner principal))
  (default-to u0 (get count (map-get? animal-count-by-owner { owner: owner })))
)

;; Get next animal ID
(define-read-only (get-next-animal-id)
  (var-get next-animal-id)
)

;; Get animal status
(define-read-only (get-animal-status (animal-id uint))
  (match (map-get? animals { animal-id: animal-id })
    animal-data (some (get status animal-data))
    none
  )
)

;; Get animal species
(define-read-only (get-animal-species (animal-id uint))
  (match (map-get? animals { animal-id: animal-id })
    animal-data (some (get species animal-data))
    none
  )
)

;; Get animal location
(define-read-only (get-animal-location (animal-id uint))
  (match (map-get? animals { animal-id: animal-id })
    animal-data (some (get location animal-data))
    none
  )
)

;; Check if owner has registered animals
(define-read-only (owner-has-animals (owner principal))
  (> (get-owner-animal-count owner) u0)
)

;; Validate animal for other contracts
(define-read-only (validate-animal-access (animal-id uint) (caller principal))
  (and
    (animal-exists animal-id)
    (is-animal-owner animal-id caller)
    (is-eq (unwrap-panic (get-animal-status animal-id)) "active")
  )
)
