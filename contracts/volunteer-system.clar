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

;; Add a single skill to a volunteer's existing skills list
(define-public (add-volunteer-skill (skill (string-ascii 50)))
    (let 
        (
            (caller tx-sender)
            (existing-profile (map-get? volunteer-profiles caller))
        )
        (match existing-profile
            profile 
            (let 
                (
                    (current-skills (get skills profile))
                    (updated-skills (unwrap-panic (as-max-len? (append current-skills skill) u10)))
                )
                (map-set volunteer-profiles caller 
                    (merge profile { skills: updated-skills })
                )
                (ok "Skill added successfully.")
            )
            (err ERR-NOT-FOUND)
        )
    )
)

;; Increment the number of hours a volunteer is available
(define-public (increment-volunteer-hours (hours-to-add uint))
    (let 
        (
            (caller tx-sender)
            (existing-profile (map-get? volunteer-profiles caller))
        )
        (match existing-profile
            profile 
            (let 
                (
                    (current-hours (get hours-available profile))
                    (updated-hours (+ current-hours hours-to-add))
                )
                (map-set volunteer-profiles caller 
                    (merge profile { hours-available: updated-hours })
                )
                (ok "Volunteer hours incremented successfully.")
            )
            (err ERR-NOT-FOUND)
        )
    )
)

;; Decrement the number of hours a volunteer is available
(define-public (decrement-volunteer-hours (hours-to-subtract uint))
    (let 
        (
            (caller tx-sender)
            (existing-profile (map-get? volunteer-profiles caller))
        )
        (match existing-profile
            profile 
            (let 
                (
                    (current-hours (get hours-available profile))
                )
                (if (>= current-hours hours-to-subtract)
                    (begin
                        (map-set volunteer-profiles caller 
                            (merge profile { hours-available: (- current-hours hours-to-subtract) })
                        )
                        (ok "Volunteer hours decremented successfully.")
                    )
                    (err ERR-INVALID-HOURS)
                )
            )
            (err ERR-NOT-FOUND)
        )
    )
)

;; Update the location for a volunteer profile
(define-public (update-volunteer-location (new-location (string-ascii 100)))
    (let 
        (
            (caller tx-sender)
            (existing-profile (map-get? volunteer-profiles caller))
        )
        (if (is-eq new-location "")
            (err ERR-INVALID-HOURS)
            (match existing-profile
                profile 
                (begin
                    (map-set volunteer-profiles caller 
                        (merge profile { location: new-location })
                    )
                    (ok "Volunteer location updated successfully.")
                )
                (err ERR-NOT-FOUND)
            )
        )
    )
)

;; Replace all skills for a volunteer profile
(define-public (replace-volunteer-skills (new-skills (list 10 (string-ascii 50))))
    (let 
        (
            (caller tx-sender)
            (existing-profile (map-get? volunteer-profiles caller))
        )
        (if (is-eq (len new-skills) u0)
            (err ERR-INVALID-SKILLS)
            (match existing-profile
                profile 
                (begin
                    (map-set volunteer-profiles caller 
                        (merge profile { skills: new-skills })
                    )
                    (ok "Volunteer skills replaced successfully.")
                )
                (err ERR-NOT-FOUND)
            )
        )
    )
)

;; Update the name for a volunteer profile
(define-public (update-volunteer-name (new-name (string-ascii 100)))
    (let 
        (
            (caller tx-sender)
            (existing-profile (map-get? volunteer-profiles caller))
        )
        (if (is-eq new-name "")
            (err ERR-INVALID-HOURS)
            (match existing-profile
                profile 
                (begin
                    (map-set volunteer-profiles caller 
                        (merge profile { name: new-name })
                    )
                    (ok "Volunteer name updated successfully.")
                )
                (err ERR-NOT-FOUND)
            )
        )
    )
)

;; Reset the available hours for a volunteer profile
(define-public (reset-volunteer-hours (new-hours uint))
    (let 
        (
            (caller tx-sender)
            (existing-profile (map-get? volunteer-profiles caller))
        )
        (if (< new-hours u1)
            (err ERR-INVALID-HOURS)
            (match existing-profile
                profile 
                (begin
                    (map-set volunteer-profiles caller 
                        (merge profile { hours-available: new-hours })
                    )
                    (ok "Volunteer hours reset successfully.")
                )
                (err ERR-NOT-FOUND)
            )
        )
    )
)

;; Create a backup of the current volunteer profile
(define-map volunteer-profile-backups 
    principal 
    {
        name: (string-ascii 100),
        location: (string-ascii 100),
        skills: (list 10 (string-ascii 50)),
        hours-available: uint
    }
)

(define-public (backup-volunteer-profile)
    (let 
        (
            (caller tx-sender)
            (existing-profile (map-get? volunteer-profiles caller))
        )
        (match existing-profile
            profile 
            (begin
                (map-set volunteer-profile-backups caller profile)
                (ok "Volunteer profile backed up successfully.")
            )
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

;; Get full volunteer profile details (name, location, skills, and hours)
(define-read-only (get-full-volunteer-profile (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            name: (get name profile),
            location: (get location profile),
            skills: (get skills profile),
            hours-available: (get hours-available profile)
        }) ;; Return the complete profile if found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get volunteer location and skills
(define-read-only (get-volunteer-location-and-skills (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            location: (get location profile),
            skills: (get skills profile)
        }) ;; Return location and skills if the profile is found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get volunteer's location and hours available
(define-read-only (get-volunteer-location-and-hours (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            location: (get location profile),
            hours-available: (get hours-available profile)
        }) ;; Return location and available hours if the profile is found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get brief volunteer profile summary: name, location, and number of skills
(define-read-only (get-volunteer-brief-summary (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            name: (get name profile),
            location: (get location profile),
            skill-count: (len (get skills profile)) ;; Count of skills
        }) ;; Return the brief summary if the profile is found
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get volunteer's availability in hours.
(define-read-only (get-volunteer-availability (user principal))
    (match (map-get? volunteer-profiles user)
        profile (ok (get hours-available profile)) ;; Return the available hours if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get the full data for a volunteer (name, location, skills, and hours).
(define-read-only (get-volunteer-profile-data (user principal))
    (match (map-get? volunteer-profiles user)
        profile (ok {
            name: (get name profile),
            location: (get location profile),
            skills: (get skills profile),
            hours-available: (get hours-available profile)
        }) ;; Return all volunteer profile data if found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get the list of skills for a volunteer.
(define-read-only (get-volunteer-skill-list (user principal))
    (match (map-get? volunteer-profiles user)
        profile (ok (get skills profile)) ;; Return the skill list if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get the location and available hours for a volunteer.
(define-read-only (get-volunteer-location-availability (user principal))
    (match (map-get? volunteer-profiles user)
        profile (ok {
            location: (get location profile),
            hours-available: (get hours-available profile)
        }) ;; Return location and availability if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Check if a volunteer has valid skills (at least one skill).
(define-read-only (get-volunteer-skill-status (user principal))
    (match (map-get? volunteer-profiles user)
        profile (if (> (len (get skills profile)) u0)
                     (ok "Valid Skills") ;; Return "Valid Skills" if skills list is non-empty
                     (ok "Invalid Skills") ;; Return "Invalid Skills" if skills list is empty
        )
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get a summary of the volunteer's skills count.
(define-read-only (get-volunteer-skills-summary (user principal))
    (match (map-get? volunteer-profiles user)
        profile (ok (len (get skills profile))) ;; Return the number of skills if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get volunteer's location and the count of their skills
(define-read-only (get-volunteer-location-skill-count (user principal))
    (match (map-get? volunteer-profiles user)
        profile (ok {
            location: (get location profile),
            skill-count: (len (get skills profile))
        }) ;; Return location and skill count if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Check if a volunteer has more than one skill.
(define-read-only (is-volunteer-has-multiple-skills (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (if (> (len (get skills profile)) u1)
                    (ok true) ;; Return true if more than one skill exists
                    (ok false)) ;; Return false if only one skill or none
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Check if the volunteer is available for a specific number of hours
(define-read-only (is-volunteer-available-for-hours (user principal) (hours uint))
    (match (map-get? volunteer-profiles user)
        profile (if (>= (get hours-available profile) hours)
                    (ok true) ;; Return true if the volunteer is available for the specified hours
                    (ok false)) ;; Return false if the volunteer is not available
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Check if a volunteer has available hours (i.e., hours-available > 0)
(define-read-only (is-volunteer-available (user principal))
    (match (map-get? volunteer-profiles user)
        profile (if (> (get hours-available profile) u0)
                     (ok true) ;; Return true if volunteer has available hours
                     (ok false)) ;; Return false if no available hours
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Check if a volunteer has any skills registered
(define-read-only (has-volunteer-skills (user principal))
    (match (map-get? volunteer-profiles user)
        profile (if (> (len (get skills profile)) u0)
                     (ok true) ;; Return true if volunteer has skills
                     (ok false)) ;; Return false if no skills
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get volunteer's full name and hours available
(define-read-only (get-volunteer-name-and-hours (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            name: (get name profile),
            hours-available: (get hours-available profile)
        }) ;; Return name and hours-available if profile is found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get volunteer's name and location
(define-read-only (get-volunteer-name-and-location (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            name: (get name profile),
            location: (get location profile)
        }) ;; Return name and location if profile is found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get volunteer's skills count and hours available
(define-read-only (get-volunteer-skills-count-and-hours (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            skill-count: (len (get skills profile)),
            hours-available: (get hours-available profile)
        }) ;; Return skill count and hours-available if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get volunteer's available hours and skill status
(define-read-only (get-volunteer-hours-and-skill-status (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            hours-available: (get hours-available profile),
            skill-status: (if (> (len (get skills profile)) u0)
                              (ok "Valid Skills")
                              (ok "Invalid Skills"))
        }) ;; Return available hours and skill status if profile is found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get all skill names for a volunteer
(define-read-only (get-all-volunteer-skills (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok (get skills profile)) ;; Return the list of skills if profile is found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get the name and location of a volunteer
(define-read-only (get-volunteer-name-location (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            name: (get name profile),
            location: (get location profile)
        }) ;; Return name and location if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get the number of skills and hours available for a volunteer
(define-read-only (get-volunteer-skills-availability (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            skill-count: (len (get skills profile)),
            hours-available: (get hours-available profile)
        }) ;; Return skill count and availability if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get the volunteer's location and a summary of their skills (number of skills)
(define-read-only (get-volunteer-location-skills-summary (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            location: (get location profile),
            skill-summary: (len (get skills profile)) ;; Number of skills
        }) ;; Return location and skill summary if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Check if the volunteer profile is incomplete (missing required fields)
(define-read-only (is-volunteer-profile-incomplete (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (if (or (is-eq (get name profile) "")
                        (is-eq (get location profile) "")
                        (is-eq (len (get skills profile)) u0))
                    (ok true) ;; Return true if profile is incomplete
                    (ok false)) ;; Return false if profile is complete
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get the volunteer's skills and hours available summary
(define-read-only (get-volunteer-skills-availability-summary (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            skills: (get skills profile),
            hours-available: (get hours-available profile)
        }) ;; Return skills and availability summary if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Check if the volunteer profile is valid (contains all necessary fields)
(define-read-only (is-volunteer-profile-valid (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (if (and (not (is-eq (get name profile) ""))
                         (not (is-eq (get location profile) ""))
                         (> (len (get skills profile)) u0)
                         (> (get hours-available profile) u0))
                    (ok true) ;; Return true if profile is valid
                    (ok false)) ;; Return false if profile is invalid
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get the hours available and location of a volunteer
(define-read-only (get-volunteer-hours-location (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok {
            hours-available: (get hours-available profile),
            location: (get location profile)
        }) ;; Return hours and location if profile found
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Get the total number of hours a volunteer is available
(define-read-only (get-volunteer-total-hours (user principal))
    (match (map-get? volunteer-profiles user)
        profile (ok (get hours-available profile)) ;; Return the total available hours
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Check if a volunteer is located in a specific location
(define-read-only (is-volunteer-in-location (user principal) (location-query (string-ascii 100)))
    (match (map-get? volunteer-profiles user)
        profile (if (is-eq (get location profile) location-query)
                      (ok true) ;; Return true if the location matches
                      (ok false)) ;; Return false if the location does not match
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Check if a volunteer has enough available hours (greater than a specific number)
(define-read-only (has-enough-available-hours (user principal) (required-hours uint))
    (match (map-get? volunteer-profiles user)
        profile (if (>= (get hours-available profile) required-hours)
                      (ok true) ;; Return true if the volunteer has enough hours
                      (ok false)) ;; Return false if the volunteer does not have enough hours
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Check if a volunteer is available for more than X hours
(define-read-only (is-volunteer-available-more-than-x (user principal) (min-hours uint))
    (match (map-get? volunteer-profiles user)
        profile (if (> (get hours-available profile) min-hours)
                    (ok true) ;; Return true if the volunteer is available for more than X hours
                    (ok false)) ;; Return false if not
        ERR-NOT-FOUND ;; Return error if profile not found
    )
)

;; Check if volunteer has a location set
(define-read-only (is-volunteer-location-set (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (if (is-eq (get location profile) "")
                     (ok false) ;; Return false if no location is set
                     (ok true)) ;; Return true if location is set
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

;; Get volunteer skills count
(define-read-only (get-volunteer-skills-count (user principal))
    (match (map-get? volunteer-profiles user) ;; Look up the profile for the given user
        profile (ok (len (get skills profile))) ;; Return the count of skills
        ERR-NOT-FOUND ;; Return error if the profile is not found
    )
)

