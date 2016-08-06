;; mach.d/dxltab.scm

;; Copyright (C) 2015 Matthew R. Wette -- all rights reserved

(define len-v
  #(1 1 1 3 0 1 1 1 3 0 3 8 7 2 3 4 5 3 4 5 7 4 6 6 8 8 3 5 2 3 2 1 2 1 1 1 
    1 1 1 1 1 1 1 3 1 3 5 4 2 1 1 3 1 1 3 1 3 1 1 1 1 1 1 1 1 1 1 1 1 5 1 3 3 
    1 3 3 1 3 1 3 1 3 1 3 3 1 3 3 3 3 1 3 1 1 1 3 1 1 1 3 1 1 1 1 4 1 2 2 2 2 
    2 2 2 2 1 2 1 3 3 4 2 2 3 5 1 1 3 4 1 1 1 1 1 1))

(define pat-v
  #(((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8)
    (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 
    . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89
    . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 
    31) (93 . 32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37) (52 . 38)
    (53 . 39) (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (101 . 45) (
    68 . 46) (57 . 47) (62 . 48) (65 . 49) (105 . 50) (72 . 51) (109 . 52) (
    110 . 53) (111 . 54) (112 . 55) (113 . 56) (114 . 57) (74 . -4) (73 . -4))
    ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (70 . 92) (106 . 
    27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14
    . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 129)) ((9 . 19) (1 . 20) (
    2 . 21) (3 . 22) (4 . 23) (5 . 25) (70 . 92) (106 . 27) (108 . 28) (75 . 
    30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 
    7) (16 . 8) (76 . 9) (77 . 128)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 
    . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2)
    (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) 
    (77 . 10) (79 . 127)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 
    25) (70 . 92) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) 
    (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 126))
    ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (70 . 92) (106 . 
    27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14
    . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 125)) ((9 . 19) (1 . 20) (
    2 . 21) (3 . 22) (4 . 23) (5 . 25) (70 . 92) (106 . 27) (108 . 28) (75 . 
    30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 
    7) (16 . 8) (76 . 9) (77 . 124)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 
    . 23) (5 . 25) (70 . 92) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1
    ) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) 
    (77 . 123)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (70 . 
    92) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (
    13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 122)) ((-1 . 
    -105)) ((-1 . -103)) ((-1 . -98)) ((17 . 118) (18 . 119) (19 . 120) (78 . 
    121) (-1 . -94)) ((20 . 115) (21 . 116) (80 . 117) (-1 . -90)) ((22 . 112)
    (23 . 113) (82 . 114) (-1 . -85)) ((27 . 108) (26 . 109) (25 . 110) (24 
    . 111) (-1 . -82)) ((29 . 106) (28 . 107) (-1 . -80)) ((66 . 105) (-1 . 
    -78)) ((30 . 104) (-1 . -76)) ((-1 . -133)) ((-1 . -132)) ((-1 . -131)) ((
    -1 . -130)) ((-1 . -129)) ((31 . 103) (-1 . -73)) ((-1 . -128)) ((11 . 1) 
    (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (
    77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 
    . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (70
    . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32) (102 
    . 33) (94 . 34) (95 . 42) (101 . 100) (5 . 101) (49 . 35) (50 . 36) (51 . 
    37) (52 . 38) (53 . 39) (54 . 40) (55 . 41) (98 . 43) (105 . 102)) ((-1 . 
    -125)) ((-1 . -124)) ((33 . 98) (32 . 99) (-1 . -70)) ((-1 . -116)) ((37 
    . 95) (35 . 96) (34 . 97) (-1 . -68)) ((38 . 75) (39 . 76) (40 . 77) (41 
    . 78) (42 . 79) (43 . 80) (44 . 81) (45 . 82) (46 . 83) (47 . 84) (48 . 85
    ) (92 . 86) (10 . 87) (8 . 88) (12 . 89) (11 . 90) (36 . 91) (9 . 19) (1 
    . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (70 . 92) (106 . 27) (108 . 28) 
    (75 . 30) (93 . 93) (76 . 94) (-1 . -114)) ((-1 . -55)) ((-1 . -53)) ((-1 
    . -41)) ((-1 . -40)) ((-1 . -39)) ((-1 . -38)) ((-1 . -37)) ((-1 . -36)) (
    (-1 . -35)) ((71 . 74) (-1 . -52)) ((-1 . -34)) ((11 . 1) (12 . 2) (66 . 3
    ) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11
    ) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9
    . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 25) (70 . 26) (
    106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32) (102 . 33) (
    94 . 34) (95 . 42) (101 . 73) (-1 . -33)) ((-1 . -31)) ((67 . 69) (11 . 1)
    (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (
    77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 
    . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 
    . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 
    32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37) (52 . 38) (53 . 39)
    (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (101 . 45) (105 . 70) (
    68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 71) (103 . 72)) ((70 . 68)) 
    ((4 . 23) (108 . 65) (70 . 66) (100 . 67)) ((11 . 1) (12 . 2) (66 . 3) (13
    . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11) (81
    . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9 . 19
    ) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 25) (70 . 63) (106 . 
    27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32) (102 . 33) (94 . 34
    ) (95 . 42) (101 . 64)) ((4 . 23) (108 . 60) (97 . 61) (99 . 62)) ((4 . 23
    ) (108 . 59)) ((73 . -7) (74 . -7)) ((73 . -6) (74 . -6)) ((73 . -5) (74 
    . -5)) ((73 . -2) (74 . -2)) ((73 . 58) (74 . -1)) ((74 . 0)) ((11 . 1) (
    12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77
    . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 
    17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 
    25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32
    ) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37) (52 . 38) (53 . 39) (
    54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (101 . 45) (68 . 46) (57 
    . 47) (62 . 48) (65 . 49) (105 . 50) (72 . 51) (109 . 52) (110 . 53) (111 
    . 54) (112 . 171) (74 . -4) (73 . -4)) ((107 . 170) (74 . -9) (73 . -9) (
    71 . -9)) ((48 . 168) (70 . 169) (71 . -44) (73 . -44) (74 . -44)) ((-1 . 
    -42)) ((71 . 167) (-1 . -30)) ((94 . 34) (95 . 42) (101 . 100) (49 . 35) (
    50 . 36) (51 . 37) (52 . 38) (53 . 39) (54 . 40) (55 . 41) (98 . 43) (105 
    . 102) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 101) (106 . 27) (
    108 . 28) (75 . 30) (93 . 32) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5)
    (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 
    12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (89 . 24) 
    (90 . 29) (91 . 31) (102 . 166)) ((64 . 165)) ((61 . 164)) ((11 . 1) (12 
    . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 
    10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) 
    (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 25) 
    (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32) (
    102 . 33) (94 . 34) (95 . 42) (73 . 161) (101 . 162) (96 . 163)) ((11 . 1)
    (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (
    77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 
    . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 
    . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 
    32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37) (52 . 38) (53 . 39)
    (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (101 . 45) (105 . 70) (
    68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 160)) ((11 . 1) (12 . 2) (66
    . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 
    . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18
    ) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 25) (70 . 26
    ) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32) (102 . 33)
    (94 . 34) (95 . 42) (101 . 159)) ((-1 . -28)) ((4 . 23) (108 . 158) (97 
    . 61) (99 . 62)) ((67 . -50) (73 . -50)) ((67 . 156) (73 . 157)) ((-1 . 
    -32)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 
    . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) 
    (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23)
    (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (
    91 . 31) (93 . 32) (102 . 33) (94 . 155)) ((-1 . -67)) ((-1 . -66)) ((-1 
    . -65)) ((-1 . -64)) ((-1 . -63)) ((-1 . -62)) ((-1 . -61)) ((-1 . -60)) (
    (-1 . -59)) ((-1 . -58)) ((-1 . -57)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4)
    (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12
    ) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 
    . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 25) (70 . 26) (106 . 27) (
    108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32) (102 . 33) (94 . 154)) (
    (4 . 23) (108 . 152) (9 . 153)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 
    23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (
    66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) (
    77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 
    . 17) (88 . 18) (89 . 24) (90 . 29) (91 . 31) (102 . 151)) ((-1 . -120)) (
    (-1 . -121)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (70 . 
    92) (106 . 27) (108 . 28) (75 . 150)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4)
    (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12
    ) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 
    . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (70 . 26) (106 . 27) (108 . 28)
    (90 . 29) (75 . 30) (91 . 31) (93 . 32) (102 . 33) (94 . 34) (95 . 42) (
    101 . 100) (5 . 101)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 
    25) (70 . 92) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (76 . 94) (10 . 87
    ) (8 . 88) (12 . 89) (11 . 90) (36 . 91) (-1 . -114)) ((-1 . -115)) ((11 
    . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 
    9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (
    87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) 
    (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93
    . 32) (102 . 33) (94 . 34) (95 . 42) (101 . 149)) ((9 . 19) (1 . 20) (2 
    . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93)
    (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (
    76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 
    15) (86 . 16) (87 . 17) (88 . 18) (89 . 24) (90 . 148)) ((9 . 19) (1 . 20)
    (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 
    . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 
    . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) 
    (85 . 15) (86 . 16) (87 . 17) (88 . 18) (89 . 24) (90 . 147)) ((9 . 19) (1
    . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30)
    (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) 
    (16 . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 
    14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (89 . 146)) ((9 . 19) (1 . 20)
    (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 
    . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 
    . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) 
    (85 . 15) (86 . 16) (87 . 17) (88 . 18) (89 . 145)) ((69 . 144)) ((49 . 35
    ) (50 . 36) (51 . 37) (52 . 38) (53 . 39) (54 . 40) (55 . 41) (98 . 43) (
    105 . 143) (-1 . -128)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 
    . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3)
    (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10)
    (79 . 142)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 
    . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (
    14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) 
    (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 141)) ((
    9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28)
    (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6)
    (20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 
    13) (84 . 14) (85 . 15) (86 . 16) (87 . 140)) ((9 . 19) (1 . 20) (2 . 21) 
    (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 
    . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 
    9) (70 . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (
    86 . 139)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 
    27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14
    . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) (
    81 . 12) (83 . 13) (84 . 14) (85 . 138)) ((9 . 19) (1 . 20) (2 . 21) (3 . 
    22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (
    12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70
    . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 137)) ((9 
    . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) (
    75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (
    20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 13
    ) (84 . 136)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 
    . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (
    14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) 
    (81 . 12) (83 . 13) (84 . 135)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 
    23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (
    66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) (
    77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 134)) ((9 . 19) (1 . 20) (2 
    . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93)
    (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (
    76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 133)) ((-1
    . -93)) ((-1 . -92)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 
    25) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (
    13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10) (
    79 . 11) (81 . 12) (83 . 132)) ((-1 . -97)) ((-1 . -96)) ((9 . 19) (1 . 20
    ) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 
    . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 
    . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 131)) ((-1 . -102)) ((-1
    . -101)) ((-1 . -100)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 
    . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3)
    (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10)
    (79 . 130)) ((-1 . -106)) ((-1 . -107)) ((-1 . -108)) ((-1 . -109)) ((-1 
    . -110)) ((-1 . -111)) ((-1 . -112)) ((-1 . -113)) ((-1 . -99)) ((17 . 118
    ) (18 . 119) (19 . 120) (78 . 121) (-1 . -95)) ((20 . 115) (21 . 116) (80 
    . 117) (-1 . -91)) ((22 . 112) (23 . 113) (82 . 114) (-1 . -89)) ((22 . 
    112) (23 . 113) (82 . 114) (-1 . -88)) ((22 . 112) (23 . 113) (82 . 114) (
    -1 . -87)) ((22 . 112) (23 . 113) (82 . 114) (-1 . -86)) ((27 . 108) (26 
    . 109) (25 . 110) (24 . 111) (-1 . -84)) ((27 . 108) (26 . 109) (25 . 110)
    (24 . 111) (-1 . -83)) ((29 . 106) (28 . 107) (-1 . -81)) ((66 . 105) (-1
    . -79)) ((30 . 104) (-1 . -77)) ((69 . 189)) ((69 . 188)) ((-1 . -126)) (
    (31 . 103) (-1 . -75)) ((31 . 103) (-1 . -74)) ((33 . 98) (32 . 99) (-1 . 
    -72)) ((33 . 98) (32 . 99) (-1 . -71)) ((36 . 187)) ((6 . 186) (-1 . -122)
    ) ((7 . 185)) ((-1 . -118)) ((-1 . -117)) ((-1 . -56)) ((-1 . -54)) ((-1 
    . -29)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (
    16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 
    15) (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 
    . 23) (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 
    30) (91 . 31) (93 . 32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37)
    (52 . 38) (53 . 39) (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (
    101 . 45) (105 . 70) (68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 184)) 
    ((48 . 168) (-1 . -44)) ((69 . 183)) ((-1 . -26)) ((-1 . -49)) ((73 . 182)
    ) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8)
    (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 
    . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89
    . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 
    31) (93 . 32) (102 . 33) (94 . 34) (95 . 42) (73 . 161) (101 . 162) (96 . 
    181)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 
    . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) 
    (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23)
    (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (
    91 . 31) (93 . 32) (102 . 33) (94 . 34) (95 . 42) (101 . 180)) ((11 . 1) (
    12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77
    . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 
    17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 
    25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32
    ) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37) (52 . 38) (53 . 39) (
    54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (101 . 45) (105 . 70) (68
    . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 179)) ((69 . 178) (71 . -55)) 
    ((4 . 23) (108 . 158) (97 . 177)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 
    . 23) (5 . 25) (106 . 27) (108 . 28) (75 . 30) (93 . 93) (11 . 1) (12 . 2)
    (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (70 . 26) 
    (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 
    . 17) (88 . 18) (89 . 24) (90 . 29) (91 . 31) (102 . 176)) ((49 . 35) (50 
    . 36) (51 . 37) (52 . 38) (53 . 39) (54 . 40) (55 . 41) (98 . 43) (105 . 
    173) (104 . 174) (69 . 175)) ((71 . 172) (73 . -8) (74 . -8)) ((73 . -3) (
    74 . -3)) ((9 . 19) (1 . 20) (2 . 21) (3 . 22) (106 . 205)) ((4 . 23) (108
    . 203) (66 . 204)) ((69 . 201) (71 . 202)) ((68 . 200)) ((-1 . -45)) ((-1
    . -43)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (
    16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 
    15) (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 
    . 23) (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 
    30) (91 . 31) (93 . 32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37)
    (52 . 38) (53 . 39) (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (
    101 . 45) (105 . 70) (68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 199)) 
    ((63 . 198) (73 . -21) (67 . -21) (74 . -21)) ((58 . 195) (59 . 196) (60 
    . 197)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (
    16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 
    15) (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 
    . 23) (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 
    30) (91 . 31) (93 . 32) (102 . 33) (94 . 34) (95 . 42) (101 . 193) (69 . 
    194)) ((-1 . -48)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) 
    (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 
    14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 
    . 22) (4 . 23) (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29
    ) (75 . 30) (91 . 31) (93 . 32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (
    51 . 37) (52 . 38) (53 . 39) (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 
    . 44) (101 . 45) (105 . 70) (68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 
    . 192)) ((67 . -51) (73 . -51)) ((-1 . -119)) ((9 . 19) (1 . 20) (2 . 21) 
    (3 . 22) (4 . 23) (5 . 25) (70 . 92) (106 . 27) (108 . 28) (75 . 191)) ((9
    . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (5 . 25) (106 . 27) (108 . 28) 
    (75 . 30) (93 . 93) (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) 
    (20 . 7) (16 . 8) (76 . 9) (70 . 26) (77 . 10) (79 . 11) (81 . 12) (83 . 
    13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (89 . 24) (90 . 29) 
    (91 . 31) (102 . 190)) ((-1 . -127)) ((-1 . -104)) ((-1 . -69)) ((-1 . 
    -123)) ((-1 . -27)) ((69 . 217)) ((-1 . -47)) ((11 . 1) (12 . 2) (66 . 3) 
    (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11) 
    (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9 
    . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 25) (70 . 26) (
    106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32) (102 . 33) (
    94 . 34) (95 . 42) (101 . 216)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 
    . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83
    . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20)
    (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 
    . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32) (102 . 33) (94 . 34) (95 . 
    42) (101 . 215)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (
    20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14
    ) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 
    22) (4 . 23) (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) 
    (75 . 30) (91 . 31) (93 . 32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51
    . 37) (52 . 38) (53 . 39) (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 
    44) (101 . 45) (105 . 70) (68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 
    214)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 
    . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) 
    (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23)
    (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (
    91 . 31) (93 . 32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37) (52 
    . 38) (53 . 39) (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (101 . 
    45) (105 . 70) (68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 213)) ((63 
    . 212) (73 . -19) (67 . -19) (74 . -19)) ((11 . 1) (12 . 2) (66 . 3) (13 
    . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 
    . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9 . 19)
    (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 25) (70 . 26) (106 . 
    27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32) (102 . 33) (94 . 34
    ) (49 . 35) (50 . 36) (51 . 37) (52 . 38) (53 . 39) (54 . 40) (55 . 41) (
    95 . 42) (98 . 43) (56 . 44) (101 . 45) (105 . 70) (68 . 46) (57 . 47) (62
    . 48) (65 . 49) (110 . 71) (103 . 211)) ((68 . 210)) ((66 . 207) (4 . 23)
    (108 . 208) (49 . 35) (50 . 36) (51 . 37) (52 . 38) (53 . 39) (54 . 40) (
    55 . 41) (98 . 43) (105 . 209)) ((69 . -13) (71 . -13)) ((4 . 23) (108 . 
    206)) ((71 . -10) (73 . -10) (74 . -10)) ((69 . -14) (71 . -14)) ((4 . 23)
    (108 . 225)) ((69 . -17) (71 . -17)) ((4 . 23) (108 . 223) (66 . 224)) ((
    11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76
    . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16
    ) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 
    24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31)
    (93 . 32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37) (52 . 38) (
    53 . 39) (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (101 . 45) (105
    . 70) (68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 71) (103 . 222)) ((
    67 . 221) (73 . 157)) ((11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 
    6) (20 . 7) (16 . 8) (76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 
    . 14) (85 . 15) (86 . 16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (
    3 . 22) (4 . 23) (89 . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 
    29) (75 . 30) (91 . 31) (93 . 32) (102 . 33) (94 . 34) (49 . 35) (50 . 36)
    (51 . 37) (52 . 38) (53 . 39) (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56
    . 44) (101 . 45) (105 . 70) (68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 
    . 220)) ((-1 . -22)) ((-1 . -23)) ((60 . 219)) ((60 . 218)) ((-1 . -46)) (
    (11 . 1) (12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (
    76 . 9) (77 . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 
    16) (87 . 17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 
    . 24) (5 . 25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 
    31) (93 . 32) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37) (52 . 38)
    (53 . 39) (54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (101 . 45) (
    105 . 70) (68 . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 229)) ((11 . 1) (
    12 . 2) (66 . 3) (13 . 4) (14 . 5) (21 . 6) (20 . 7) (16 . 8) (76 . 9) (77
    . 10) (79 . 11) (81 . 12) (83 . 13) (84 . 14) (85 . 15) (86 . 16) (87 . 
    17) (88 . 18) (9 . 19) (1 . 20) (2 . 21) (3 . 22) (4 . 23) (89 . 24) (5 . 
    25) (70 . 26) (106 . 27) (108 . 28) (90 . 29) (75 . 30) (91 . 31) (93 . 32
    ) (102 . 33) (94 . 34) (49 . 35) (50 . 36) (51 . 37) (52 . 38) (53 . 39) (
    54 . 40) (55 . 41) (95 . 42) (98 . 43) (56 . 44) (101 . 45) (105 . 70) (68
    . 46) (57 . 47) (62 . 48) (65 . 49) (110 . 228)) ((-1 . -20)) ((73 . -12)
    (74 . -12)) ((67 . 227) (73 . 157)) ((69 . -15) (71 . -15)) ((4 . 23) (
    108 . 226)) ((69 . -18) (71 . -18)) ((69 . -16) (71 . -16)) ((73 . -11) (
    74 . -11)) ((-1 . -24)) ((-1 . -25))))

(define rto-v
  #(#f 114 113 113 112 112 112 112 111 107 107 109 109 104 104 104 104 104 
    104 110 110 110 110 110 110 110 110 110 110 110 110 110 110 110 105 98 98 
    98 98 98 98 98 99 99 97 97 100 100 96 96 103 103 101 95 95 94 94 92 92 92 
    92 92 92 92 92 92 92 92 102 102 91 91 91 90 90 90 89 89 88 88 87 87 86 86 
    86 85 85 85 85 85 84 84 82 82 83 83 80 80 81 81 78 78 78 79 79 77 77 77 77
    77 77 77 77 77 76 76 93 93 93 93 93 93 93 93 75 75 75 75 75 108 106 106 
    106 106))

(define mtab
  '(($chlit . 1) ($float . 2) ($fixed . 3) ($ident . 4) ("current" . 5) (
    "by" . 6) ("]" . 7) ("[" . 8) ($string . 9) ("." . 10) ("--" . 11) ("++" 
    . 12) ("~" . 13) ("!" . 14) (UNARY . 15) ("sizeof" . 16) ("%" . 17) ("/" 
    . 18) ("*" . 19) ("-" . 20) ("+" . 21) (">>" . 22) ("<<" . 23) (">=" . 24)
    (">" . 25) ("<=" . 26) ("<" . 27) ("!=" . 28) ("==" . 29) ("^" . 30) ("|"
    . 31) ("and" . 32) ("&&" . 33) ("or" . 34) ("||" . 35) (":" . 36) ("?" . 
    37) ("|=" . 38) ("^=" . 39) ("&=" . 40) (">>=" . 41) ("<<=" . 42) ("%=" . 
    43) ("/=" . 44) ("*=" . 45) ("-=" . 46) ("+=" . 47) ("=" . 48) (
    built-in-type . 49) ("string" . 50) ("void" . 51) ("real" . 52) ("int" . 
    53) ("char" . 54) ("bool" . 55) ("return" . 56) ("while" . 57) ("<-" . 58)
    ("->" . 59) ("do" . 60) ("in" . 61) ("for" . 62) ("else" . 63) ("then" . 
    64) ("if" . 65) ("&" . 66) ("}" . 67) ("{" . 68) (")" . 69) ("(" . 70) (
    "," . 71) ("pragma" . 72) (";" . 73) ($end . 74)))

;;; end tables