;; ========================
;; Volunteer Profile Management Contract
;; ========================
;;
;; This smart contract allows volunteers to register, update, and retrieve
;; their profiles. Each volunteer's profile includes their name, location,
;; skills, and hours available. The contract provides functions to:
;; 1. Register a new volunteer.
;; 2. Update an existing volunteer profile.
;; 3. Retrieve a volunteer's profile and skills.
;;
;; Errors are handled for cases like missing or invalid data, duplicate profiles,
;; and profile not found.
;;
;; Contract constants define error codes for better error handling.
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

;; Update volunteer profile
(define-public (update-volunteer
    (name (string-ascii 100)) ;; Volunteer name
    (location (string-ascii 100)) ;; Volunteer location
    (skills (list 10 (string-ascii 50))) ;; List of skills (up to 10 skills, each up to 50 characters)
    (hours-available uint) ;; Number of hours volunteer is available
)
    (let
        (
            (caller tx-sender) ;; The sender of the transaction (i.e., the volunteer)
            (existing-profile (map-get? volunteer-profiles caller)) ;; Check if the volunteer has an existing profile
        )
        ;; If the volunteer profile exists, update the profile
        (if (is-some existing-profile)
            (begin
                ;; Validate input fields (name, location, skills, hours-available)
                (if (or (is-eq name "")
                        (is-eq location "")
                        (is-eq (len skills) u0) ;; Ensure at least one skill is provided
                        (< hours-available u1)) ;; Ensure a valid number of hours is provided
                    (err ERR-INVALID-HOURS) ;; Return error if validation fails
                    (begin
                        ;; Update the volunteer profile in the volunteer-profiles map
                        (map-set volunteer-profiles caller
                            {
                                name: name,
                                location: location,
                                skills: skills,
                                hours-available: hours-available
                            }
                        )
                        (ok "Volunteer profile updated successfully.") ;; Success message
                    )
                )
            )
            ;; Return error if the volunteer profile is not found
            (err ERR-NOT-FOUND)
        )
    )
)


;; ========================
;; SECTION 4: READ-ONLY FUNCTIONS
;; ========================

;; Get volunteer profile
(define-read-only (get-volunteer-profile (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok profile) ;; Return the volunteer profile if found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get volunteer skills
(define-read-only (get-volunteer-skills (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok (get skills profile)) ;; Return the skills list if the profile is found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get volunteer available hours
(define-read-only (get-volunteer-hours (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok (get hours-available profile)) ;; Return the hours available if the profile is found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get volunteer location
(define-read-only (get-volunteer-location (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok (get location profile)) ;; Return the location if the profile is found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Check if volunteer is registered
(define-read-only (is-volunteer-registered (user principal))
    (if (is-some (map-get? volunteer-profiles user))
        (ok true) ;; Return true if the volunteer is registered
        (ok false) ;; Return false if the volunteer is not registered
    )
)

;; Get volunteer name
(define-read-only (get-volunteer-name (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok (get name profile)) ;; Return the name if the profile is found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get the number of skills for a volunteer
(define-read-only (get-volunteer-skill-count (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok (len (get skills profile))) ;; Return the number of skills for the volunteer
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get a summary of the volunteer profile: name, location, and number of skills
(define-read-only (get-volunteer-summary (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            name: (get name profile),
            location: (get location profile),
            skill-count: (len (get skills profile)) ;; Count of skills
        }) ;; Return the summary if the profile is found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Check volunteer profile status (Registered/Not Registered)
(define-read-only (get-volunteer-status (user principal))
    (if (is-some (map-get? volunteer-profiles user))
        (ok "Registered") ;; Return "Registered" if the volunteer is found
        (ok "Not Registered") ;; Return "Not Registered" if the volunteer is not found
    )
)

;; Check if volunteer has valid skills
(define-read-only (is-volunteer-skills-valid (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (if (> (len (get skills profile)) u0)
                    (ok true) ;; Return true if skills list is not empty
                    (ok false)) ;; Return false if skills list is empty
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)
