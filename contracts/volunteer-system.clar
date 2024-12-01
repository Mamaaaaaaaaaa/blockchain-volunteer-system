;; ========================
;; Volunteer Profile Management Contract
;; ========================
;;
;; This smart contract allows volunteers to register, update, and retrieve
;; their profiles. Each volunteer's profile includes their name, location,
;; skills, and hours available. 
;; ========================

;; ========================
;; SECTION 1: CONSTANTS
;; ========================

;; Define constants for error handling
(define-constant ERR-NOT-FOUND (err u404)) ;; Error: Volunteer profile not found
(define-constant ERR-ALREADY-EXISTS (err u409)) ;; Error: Volunteer already registered
(define-constant ERR-INVALID-SKILLS (err u403)) ;; Error: Invalid skills input
(define-constant ERR-INVALID-HOURS (err u400)) ;; Error: Invalid hours input


;; ========================
;; SECTION 2: DATA STRUCTURES
;; ========================

;; Define the map for storing volunteer profiles
(define-map volunteer-profiles
    principal ;; Key: Principal (unique identifier of the volunteer)
    {
        name: (string-ascii 100), ;; Name of the volunteer
        location: (string-ascii 100), ;; Location of the volunteer
        skills: (list 10 (string-ascii 50)), ;; List of skills (up to 10 skills, each up to 50 characters)
        hours-available: uint ;; Number of hours the volunteer is available
    }
)

;; ========================
;; SECTION 3: PUBLIC FUNCTIONS
;; ========================

;; Register new volunteer profile
(define-public (register-volunteer
    (name (string-ascii 100)) ;; Volunteer name
    (location (string-ascii 100)) ;; Volunteer location
    (skills (list 10 (string-ascii 50))) ;; List of skills (up to 10 skills, each up to 50 characters)
    (hours-available uint) ;; Number of hours volunteer is available
)
    (let
        (
            (caller tx-sender) ;; The sender of the transaction (i.e., the volunteer)
            (existing-profile (map-get? volunteer-profiles caller)) ;; Check if the volunteer already has a profile
        )
        ;; If the volunteer profile doesn't exist, register the new volunteer
        (if (is-none existing-profile)
            (begin
                ;; Validate input fields (name, location, skills, hours-available)
                (if (or (is-eq name "")
                        (is-eq location "")
                        (is-eq (len skills) u0) ;; Ensure at least one skill is provided
                        (< hours-available u1)) ;; Ensure a valid number of hours is provided
                    (err ERR-INVALID-HOURS) ;; Return error if validation fails
                    (begin
                        ;; Store the new volunteer profile in the volunteer-profiles map
                        (map-set volunteer-profiles caller
                            {
                                name: name,
                                location: location,
                                skills: skills,
                                hours-available: hours-available
                            }
                        )
                        (ok "Volunteer registered successfully.") ;; Success message
                    )
                )
            )
            ;; Return error if volunteer already exists
            (err ERR-ALREADY-EXISTS)
        )
    )
)
