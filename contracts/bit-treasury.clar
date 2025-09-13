;; Title: BitTreasury - Bitcoin-Native Decentralized Autonomous Organization
;;
;; Summary: A sophisticated DAO treasury management protocol built on Stacks Layer 2,
;;          enabling secure collective fund management, democratic governance, and 
;;          transparent proposal execution with Bitcoin-level security guarantees.
;;
;; Description: BitTreasury revolutionizes community-driven treasury management by 
;;              combining Bitcoin's security with Stacks' smart contract capabilities.
;;              Participants stake STX tokens to earn voting power, propose funding
;;              initiatives, and collectively decide on resource allocation through
;;              weighted democratic voting. Features time-locked deposits, automated
;;              proposal execution, and transparent fund management - creating a
;;              trustless environment for community-driven financial decisions.
;;              Perfect for DAOs, investment clubs, and collective funding initiatives
;;              seeking Bitcoin-native security with advanced governance mechanisms.

;; ERROR CONSTANTS

(define-constant err-owner-only (err u100))
(define-constant err-not-initialized (err u101))
(define-constant err-already-initialized (err u102))
(define-constant err-insufficient-balance (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-unauthorized (err u105))
(define-constant err-proposal-not-found (err u106))
(define-constant err-proposal-expired (err u107))
(define-constant err-already-voted (err u108))
(define-constant err-below-minimum (err u109))
(define-constant err-locked-period (err u110))
(define-constant err-transfer-failed (err u111))
(define-constant err-invalid-duration (err u112))
(define-constant err-zero-amount (err u113))
(define-constant err-invalid-target (err u114))
(define-constant err-invalid-description (err u115))
(define-constant err-invalid-proposal-id (err u116))
(define-constant err-invalid-vote (err u117))

;; PROTOCOL CONSTANTS

(define-constant contract-owner tx-sender)
(define-constant minimum-duration u144) ;; Minimum 1 day (assuming 10min blocks)
(define-constant maximum-duration u20160) ;; Maximum 14 days
(define-constant default-minimum-deposit u1000000) ;; 1 STX in microSTX
(define-constant default-lock-period u1440) ;; ~10 days in blocks

;; STATE VARIABLES

(define-data-var total-supply uint u0)
(define-data-var minimum-deposit uint default-minimum-deposit)
(define-data-var lock-period uint default-lock-period)
(define-data-var initialized bool false)
(define-data-var last-rebalance uint u0)
(define-data-var proposal-count uint u0)

;; DATA STRUCTURES

;; User governance token balances
(define-map balances
  principal
  uint
)

;; User deposit information with time locks
(define-map deposits
  principal
  {
    amount: uint,
    lock-until: uint,
    last-reward-block: uint,
  }
)

;; Governance proposals for fund allocation
(define-map proposals
  uint
  {
    proposer: principal,
    description: (string-ascii 256),
    amount: uint,
    target: principal,
    expires-at: uint,
    executed: bool,
    yes-votes: uint,
    no-votes: uint,
  }
)

;; Voting records to prevent double voting
(define-map votes
  {
    proposal-id: uint,
    voter: principal,
  }
  bool
)

;; PRIVATE UTILITY FUNCTIONS

(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner)
)