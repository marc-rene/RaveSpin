extends Object

# Each Scale/mode will be a prime number, 
# the value will then be the scale * note (1-7) (A->G# / Ab)
enum E_MUSIC_KEYS {
    # Note multipliers (prefer sharps):
    # A=1, As=2, B=3, C=4, Cs=5, D=6, Ds=7, E=8, F=9, Fs=10, G=11, Gs=12
    #
    # Scale primes (each type gets its own prime):
    # Major = 3  # major (Ionian)
    # Natural_Minor = 7  # natural minor (Aeolian)
    # Dorian = 11  # dorian
    # Phrygian = 13  # phrygian
    # Lydian = 17  # lydian
    # Mixolydian = 19  # mixolydian
    # Locrian = 23  # locrian
    # Harmonic_Minor = 29  # harmonic minor
    # Melodic_Minor = 31  # melodic minor
    # Pentatonic_Major = 37  # major pentatonic
    # Pentatonic_Minor = 41  # minor pentatonic
    # Blues_Minor = 43  # minor blues
    # Blues_Major = 47  # major blues
    # Whole_Tone = 53  # whole tone
    # Chromatic = 59  # chromatic
    # Diminished_WholeHalf = 61  # diminished (octatonic, whole-half)
    # Diminished_HalfWhole = 67  # diminished (octatonic, half-whole)
    # Altered = 71  # altered (super locrian)
    # Phrygian_Dominant = 73  # phrygian dominant
    # Lydian_Dominant = 79  # lydian dominant
    # Neapolitan_Minor = 83  # neapolitan minor
    # Neapolitan_Major = 89  # neapolitan major
    # Double_Harmonic_Major = 97  # double harmonic major (Byzantine)
    # Hungarian_Minor = 101  # hungarian minor
    # Hungarian_Major = 103  # hungarian major
    # Persian = 107  # persian
    # Enigmatic = 109  # enigmatic
    # Spanish_8_Tone = 113  # spanish 8-tone (flamenco)
    # Bebop_Major = 127  # bebop major
    # Bebop_Dorian = 131  # bebop dorian
    # Bebop_Mixolydian = 137  # bebop mixolydian
    # Bebop_Minor = 139  # bebop minor (aeolian bebop)
    # Insen = 149  # insen (Japanese)
    # Hirajoshi = 151  # hirajoshi (Japanese)
    # Kumoi = 157  # kumoi (Japanese)
    # Pelog = 163  # pelog (Indonesian)
    # Prometheus = 167  # prometheus
    # Ukrainian_Dorian = 173  # ukrainian dorian (dorian #4)
    # Lydian_Augmented = 179  # lydian augmented
    # Lydian_Minor = 181  # lydian minor
    # Major_Locrian = 191  # major locrian
    # Half_Diminished = 197  # half-diminished (locrian #2)
    #
    # Popped all values into excel and found 3 duplicates. these have been manually changed to "Special cases"


    A_Major = 3, # A major (Ionian)
    As_Major = 6, # A-sharp major (Ionian)
    B_Major = 9, # B major (Ionian)
    C_Major = 12, # C major (Ionian)
    Cs_Major = 15, # C-sharp major (Ionian)
    D_Major = 18, # D major (Ionian)
    # SPECIAL CASE KEY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Ds_Major = 2, # D-sharp major (Ionian)
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    E_Major = 24, # E major (Ionian)
    F_Major = 27, # F major (Ionian)
    Fs_Major = 30, # F-sharp major (Ionian)
    # SPECIAL CASE KEY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    G_Major = 4, # G major (Ionian)
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Gs_Major = 36, # G-sharp major (Ionian)
    
    A_Natural_Minor = 7, # A natural minor (Aeolian)
    As_Natural_Minor = 14, # A-sharp natural minor (Aeolian)
    B_Natural_Minor = 21, # B natural minor (Aeolian)
    C_Natural_Minor = 28, # C natural minor (Aeolian)
    Cs_Natural_Minor = 35, # C-sharp natural minor (Aeolian)
    D_Natural_Minor = 42, # D natural minor (Aeolian)
    Ds_Natural_Minor = 49, # D-sharp natural minor (Aeolian)
    E_Natural_Minor = 56, # E natural minor (Aeolian)
    F_Natural_Minor = 63, # F natural minor (Aeolian)
    Fs_Natural_Minor = 70, # F-sharp natural minor (Aeolian)
    # SPECIAL CASE KEY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    G_Natural_Minor = 8, # G natural minor (Aeolian)
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Gs_Natural_Minor = 84, # G-sharp natural minor (Aeolian)
    
    A_Dorian = 11, # A dorian
    As_Dorian = 22, # A-sharp dorian
    B_Dorian = 33, # B dorian
    C_Dorian = 44, # C dorian
    Cs_Dorian = 55, # C-sharp dorian
    D_Dorian = 66, # D dorian
    Ds_Dorian = 77, # D-sharp dorian
    E_Dorian = 88, # E dorian
    F_Dorian = 99, # F dorian
    Fs_Dorian = 110, # F-sharp dorian
    G_Dorian = 121, # G dorian
    Gs_Dorian = 132, # G-sharp dorian
    
    A_Phrygian = 13, # A phrygian
    As_Phrygian = 26, # A-sharp phrygian
    B_Phrygian = 39, # B phrygian
    C_Phrygian = 52, # C phrygian
    Cs_Phrygian = 65, # C-sharp phrygian
    D_Phrygian = 78, # D phrygian
    Ds_Phrygian = 91, # D-sharp phrygian
    E_Phrygian = 104, # E phrygian
    F_Phrygian = 117, # F phrygian
    Fs_Phrygian = 130, # F-sharp phrygian
    G_Phrygian = 143, # G phrygian
    Gs_Phrygian = 156, # G-sharp phrygian
    
    A_Lydian = 17, # A lydian
    As_Lydian = 34, # A-sharp lydian
    B_Lydian = 51, # B lydian
    C_Lydian = 68, # C lydian
    Cs_Lydian = 85, # C-sharp lydian
    D_Lydian = 102, # D lydian
    Ds_Lydian = 119, # D-sharp lydian
    E_Lydian = 136, # E lydian
    F_Lydian = 153, # F lydian
    Fs_Lydian = 170, # F-sharp lydian
    G_Lydian = 187, # G lydian
    Gs_Lydian = 204, # G-sharp lydian
    
    A_Mixolydian = 19, # A mixolydian
    As_Mixolydian = 38, # A-sharp mixolydian
    B_Mixolydian = 57, # B mixolydian
    C_Mixolydian = 76, # C mixolydian
    Cs_Mixolydian = 95, # C-sharp mixolydian
    D_Mixolydian = 114, # D mixolydian
    Ds_Mixolydian = 133, # D-sharp mixolydian
    E_Mixolydian = 152, # E mixolydian
    F_Mixolydian = 171, # F mixolydian
    Fs_Mixolydian = 190, # F-sharp mixolydian
    G_Mixolydian = 209, # G mixolydian
    Gs_Mixolydian = 228, # G-sharp mixolydian
    
    A_Locrian = 23, # A locrian
    As_Locrian = 46, # A-sharp locrian
    B_Locrian = 69, # B locrian
    C_Locrian = 92, # C locrian
    Cs_Locrian = 115, # C-sharp locrian
    D_Locrian = 138, # D locrian
    Ds_Locrian = 161, # D-sharp locrian
    E_Locrian = 184, # E locrian
    F_Locrian = 207, # F locrian
    Fs_Locrian = 230, # F-sharp locrian
    G_Locrian = 253, # G locrian
    Gs_Locrian = 276, # G-sharp locrian
    
    A_Harmonic_Minor = 29, # A harmonic minor
    As_Harmonic_Minor = 58, # A-sharp harmonic minor
    B_Harmonic_Minor = 87, # B harmonic minor
    C_Harmonic_Minor = 116, # C harmonic minor
    Cs_Harmonic_Minor = 145, # C-sharp harmonic minor
    D_Harmonic_Minor = 174, # D harmonic minor
    Ds_Harmonic_Minor = 203, # D-sharp harmonic minor
    E_Harmonic_Minor = 232, # E harmonic minor
    F_Harmonic_Minor = 261, # F harmonic minor
    Fs_Harmonic_Minor = 290, # F-sharp harmonic minor
    G_Harmonic_Minor = 319, # G harmonic minor
    Gs_Harmonic_Minor = 348, # G-sharp harmonic minor
    
    A_Melodic_Minor = 31, # A melodic minor
    As_Melodic_Minor = 62, # A-sharp melodic minor
    B_Melodic_Minor = 93, # B melodic minor
    C_Melodic_Minor = 124, # C melodic minor
    Cs_Melodic_Minor = 155, # C-sharp melodic minor
    D_Melodic_Minor = 186, # D melodic minor
    Ds_Melodic_Minor = 217, # D-sharp melodic minor
    E_Melodic_Minor = 248, # E melodic minor
    F_Melodic_Minor = 279, # F melodic minor
    Fs_Melodic_Minor = 310, # F-sharp melodic minor
    G_Melodic_Minor = 341, # G melodic minor
    Gs_Melodic_Minor = 372, # G-sharp melodic minor
    
    A_Pentatonic_Major = 37, # A major pentatonic
    As_Pentatonic_Major = 74, # A-sharp major pentatonic
    B_Pentatonic_Major = 111, # B major pentatonic
    C_Pentatonic_Major = 148, # C major pentatonic
    Cs_Pentatonic_Major = 185, # C-sharp major pentatonic
    D_Pentatonic_Major = 222, # D major pentatonic
    Ds_Pentatonic_Major = 259, # D-sharp major pentatonic
    E_Pentatonic_Major = 296, # E major pentatonic
    F_Pentatonic_Major = 333, # F major pentatonic
    Fs_Pentatonic_Major = 370, # F-sharp major pentatonic
    G_Pentatonic_Major = 407, # G major pentatonic
    Gs_Pentatonic_Major = 444, # G-sharp major pentatonic
    
    A_Pentatonic_Minor = 41, # A minor pentatonic
    As_Pentatonic_Minor = 82, # A-sharp minor pentatonic
    B_Pentatonic_Minor = 123, # B minor pentatonic
    C_Pentatonic_Minor = 164, # C minor pentatonic
    Cs_Pentatonic_Minor = 205, # C-sharp minor pentatonic
    D_Pentatonic_Minor = 246, # D minor pentatonic
    Ds_Pentatonic_Minor = 287, # D-sharp minor pentatonic
    E_Pentatonic_Minor = 328, # E minor pentatonic
    F_Pentatonic_Minor = 369, # F minor pentatonic
    Fs_Pentatonic_Minor = 410, # F-sharp minor pentatonic
    G_Pentatonic_Minor = 451, # G minor pentatonic
    Gs_Pentatonic_Minor = 492, # G-sharp minor pentatonic
    
    A_Blues_Minor = 43, # A minor blues
    As_Blues_Minor = 86, # A-sharp minor blues
    B_Blues_Minor = 129, # B minor blues
    C_Blues_Minor = 172, # C minor blues
    Cs_Blues_Minor = 215, # C-sharp minor blues
    D_Blues_Minor = 258, # D minor blues
    Ds_Blues_Minor = 301, # D-sharp minor blues
    E_Blues_Minor = 344, # E minor blues
    F_Blues_Minor = 387, # F minor blues
    Fs_Blues_Minor = 430, # F-sharp minor blues
    G_Blues_Minor = 473, # G minor blues
    Gs_Blues_Minor = 516, # G-sharp minor blues
    
    A_Blues_Major = 47, # A major blues
    As_Blues_Major = 94, # A-sharp major blues
    B_Blues_Major = 141, # B major blues
    C_Blues_Major = 188, # C major blues
    Cs_Blues_Major = 235, # C-sharp major blues
    D_Blues_Major = 282, # D major blues
    Ds_Blues_Major = 329, # D-sharp major blues
    E_Blues_Major = 376, # E major blues
    F_Blues_Major = 423, # F major blues
    Fs_Blues_Major = 470, # F-sharp major blues
    G_Blues_Major = 517, # G major blues
    Gs_Blues_Major = 564, # G-sharp major blues
    
    A_Whole_Tone = 53, # A whole tone
    As_Whole_Tone = 106, # A-sharp whole tone
    B_Whole_Tone = 159, # B whole tone
    C_Whole_Tone = 212, # C whole tone
    Cs_Whole_Tone = 265, # C-sharp whole tone
    D_Whole_Tone = 318, # D whole tone
    Ds_Whole_Tone = 371, # D-sharp whole tone
    E_Whole_Tone = 424, # E whole tone
    F_Whole_Tone = 477, # F whole tone
    Fs_Whole_Tone = 530, # F-sharp whole tone
    G_Whole_Tone = 583, # G whole tone
    Gs_Whole_Tone = 636, # G-sharp whole tone
    
    A_Chromatic = 59, # A chromatic
    As_Chromatic = 118, # A-sharp chromatic
    B_Chromatic = 177, # B chromatic
    C_Chromatic = 236, # C chromatic
    Cs_Chromatic = 295, # C-sharp chromatic
    D_Chromatic = 354, # D chromatic
    Ds_Chromatic = 413, # D-sharp chromatic
    E_Chromatic = 472, # E chromatic
    F_Chromatic = 531, # F chromatic
    Fs_Chromatic = 590, # F-sharp chromatic
    G_Chromatic = 649, # G chromatic
    Gs_Chromatic = 708, # G-sharp chromatic
    
    A_Diminished_WholeHalf = 61, # A diminished (octatonic, whole-half)
    As_Diminished_WholeHalf = 122, # A-sharp diminished (octatonic, whole-half)
    B_Diminished_WholeHalf = 183, # B diminished (octatonic, whole-half)
    C_Diminished_WholeHalf = 244, # C diminished (octatonic, whole-half)
    Cs_Diminished_WholeHalf = 305, # C-sharp diminished (octatonic, whole-half)
    D_Diminished_WholeHalf = 366, # D diminished (octatonic, whole-half)
    Ds_Diminished_WholeHalf = 427, # D-sharp diminished (octatonic, whole-half)
    E_Diminished_WholeHalf = 488, # E diminished (octatonic, whole-half)
    F_Diminished_WholeHalf = 549, # F diminished (octatonic, whole-half)
    Fs_Diminished_WholeHalf = 610, # F-sharp diminished (octatonic, whole-half)
    G_Diminished_WholeHalf = 671, # G diminished (octatonic, whole-half)
    Gs_Diminished_WholeHalf = 732, # G-sharp diminished (octatonic, whole-half)
    
    A_Diminished_HalfWhole = 67, # A diminished (octatonic, half-whole)
    As_Diminished_HalfWhole = 134, # A-sharp diminished (octatonic, half-whole)
    B_Diminished_HalfWhole = 201, # B diminished (octatonic, half-whole)
    C_Diminished_HalfWhole = 268, # C diminished (octatonic, half-whole)
    Cs_Diminished_HalfWhole = 335, # C-sharp diminished (octatonic, half-whole)
    D_Diminished_HalfWhole = 402, # D diminished (octatonic, half-whole)
    Ds_Diminished_HalfWhole = 469, # D-sharp diminished (octatonic, half-whole)
    E_Diminished_HalfWhole = 536, # E diminished (octatonic, half-whole)
    F_Diminished_HalfWhole = 603, # F diminished (octatonic, half-whole)
    Fs_Diminished_HalfWhole = 670, # F-sharp diminished (octatonic, half-whole)
    G_Diminished_HalfWhole = 737, # G diminished (octatonic, half-whole)
    Gs_Diminished_HalfWhole = 804, # G-sharp diminished (octatonic, half-whole)
    
    A_Altered = 71, # A altered (super locrian)
    As_Altered = 142, # A-sharp altered (super locrian)
    B_Altered = 213, # B altered (super locrian)
    C_Altered = 284, # C altered (super locrian)
    Cs_Altered = 355, # C-sharp altered (super locrian)
    D_Altered = 426, # D altered (super locrian)
    Ds_Altered = 497, # D-sharp altered (super locrian)
    E_Altered = 568, # E altered (super locrian)
    F_Altered = 639, # F altered (super locrian)
    Fs_Altered = 710, # F-sharp altered (super locrian)
    G_Altered = 781, # G altered (super locrian)
    Gs_Altered = 852, # G-sharp altered (super locrian)
    
    A_Phrygian_Dominant = 73, # A phrygian dominant
    As_Phrygian_Dominant = 146, # A-sharp phrygian dominant
    B_Phrygian_Dominant = 219, # B phrygian dominant
    C_Phrygian_Dominant = 292, # C phrygian dominant
    Cs_Phrygian_Dominant = 365, # C-sharp phrygian dominant
    D_Phrygian_Dominant = 438, # D phrygian dominant
    Ds_Phrygian_Dominant = 511, # D-sharp phrygian dominant
    E_Phrygian_Dominant = 584, # E phrygian dominant
    F_Phrygian_Dominant = 657, # F phrygian dominant
    Fs_Phrygian_Dominant = 730, # F-sharp phrygian dominant
    G_Phrygian_Dominant = 803, # G phrygian dominant
    Gs_Phrygian_Dominant = 876, # G-sharp phrygian dominant
    
    A_Lydian_Dominant = 79, # A lydian dominant
    As_Lydian_Dominant = 158, # A-sharp lydian dominant
    B_Lydian_Dominant = 237, # B lydian dominant
    C_Lydian_Dominant = 316, # C lydian dominant
    Cs_Lydian_Dominant = 395, # C-sharp lydian dominant
    D_Lydian_Dominant = 474, # D lydian dominant
    Ds_Lydian_Dominant = 553, # D-sharp lydian dominant
    E_Lydian_Dominant = 632, # E lydian dominant
    F_Lydian_Dominant = 711, # F lydian dominant
    Fs_Lydian_Dominant = 790, # F-sharp lydian dominant
    G_Lydian_Dominant = 869, # G lydian dominant
    Gs_Lydian_Dominant = 948, # G-sharp lydian dominant
    
    A_Neapolitan_Minor = 83, # A neapolitan minor
    As_Neapolitan_Minor = 166, # A-sharp neapolitan minor
    B_Neapolitan_Minor = 249, # B neapolitan minor
    C_Neapolitan_Minor = 332, # C neapolitan minor
    Cs_Neapolitan_Minor = 415, # C-sharp neapolitan minor
    D_Neapolitan_Minor = 498, # D neapolitan minor
    Ds_Neapolitan_Minor = 581, # D-sharp neapolitan minor
    E_Neapolitan_Minor = 664, # E neapolitan minor
    F_Neapolitan_Minor = 747, # F neapolitan minor
    Fs_Neapolitan_Minor = 830, # F-sharp neapolitan minor
    G_Neapolitan_Minor = 913, # G neapolitan minor
    Gs_Neapolitan_Minor = 996, # G-sharp neapolitan minor
    
    A_Neapolitan_Major = 89, # A neapolitan major
    As_Neapolitan_Major = 178, # A-sharp neapolitan major
    B_Neapolitan_Major = 267, # B neapolitan major
    C_Neapolitan_Major = 356, # C neapolitan major
    Cs_Neapolitan_Major = 445, # C-sharp neapolitan major
    D_Neapolitan_Major = 534, # D neapolitan major
    Ds_Neapolitan_Major = 623, # D-sharp neapolitan major
    E_Neapolitan_Major = 712, # E neapolitan major
    F_Neapolitan_Major = 801, # F neapolitan major
    Fs_Neapolitan_Major = 890, # F-sharp neapolitan major
    G_Neapolitan_Major = 979, # G neapolitan major
    Gs_Neapolitan_Major = 1068, # G-sharp neapolitan major
    
    A_Double_Harmonic_Major = 97, # A double harmonic major (Byzantine)
    As_Double_Harmonic_Major = 194, # A-sharp double harmonic major (Byzantine)
    B_Double_Harmonic_Major = 291, # B double harmonic major (Byzantine)
    C_Double_Harmonic_Major = 388, # C double harmonic major (Byzantine)
    Cs_Double_Harmonic_Major = 485, # C-sharp double harmonic major (Byzantine)
    D_Double_Harmonic_Major = 582, # D double harmonic major (Byzantine)
    Ds_Double_Harmonic_Major = 679, # D-sharp double harmonic major (Byzantine)
    E_Double_Harmonic_Major = 776, # E double harmonic major (Byzantine)
    F_Double_Harmonic_Major = 873, # F double harmonic major (Byzantine)
    Fs_Double_Harmonic_Major = 970, # F-sharp double harmonic major (Byzantine)
    G_Double_Harmonic_Major = 1067, # G double harmonic major (Byzantine)
    Gs_Double_Harmonic_Major = 1164, # G-sharp double harmonic major (Byzantine)
    
    A_Hungarian_Minor = 101, # A hungarian minor
    As_Hungarian_Minor = 202, # A-sharp hungarian minor
    B_Hungarian_Minor = 303, # B hungarian minor
    C_Hungarian_Minor = 404, # C hungarian minor
    Cs_Hungarian_Minor = 505, # C-sharp hungarian minor
    D_Hungarian_Minor = 606, # D hungarian minor
    Ds_Hungarian_Minor = 707, # D-sharp hungarian minor
    E_Hungarian_Minor = 808, # E hungarian minor
    F_Hungarian_Minor = 909, # F hungarian minor
    Fs_Hungarian_Minor = 1010, # F-sharp hungarian minor
    G_Hungarian_Minor = 1111, # G hungarian minor
    Gs_Hungarian_Minor = 1212, # G-sharp hungarian minor
    
    A_Hungarian_Major = 103, # A hungarian major
    As_Hungarian_Major = 206, # A-sharp hungarian major
    B_Hungarian_Major = 309, # B hungarian major
    C_Hungarian_Major = 412, # C hungarian major
    Cs_Hungarian_Major = 515, # C-sharp hungarian major
    D_Hungarian_Major = 618, # D hungarian major
    Ds_Hungarian_Major = 721, # D-sharp hungarian major
    E_Hungarian_Major = 824, # E hungarian major
    F_Hungarian_Major = 927, # F hungarian major
    Fs_Hungarian_Major = 1030, # F-sharp hungarian major
    G_Hungarian_Major = 1133, # G hungarian major
    Gs_Hungarian_Major = 1236, # G-sharp hungarian major
    
    A_Persian = 107, # A persian
    As_Persian = 214, # A-sharp persian
    B_Persian = 321, # B persian
    C_Persian = 428, # C persian
    Cs_Persian = 535, # C-sharp persian
    D_Persian = 642, # D persian
    Ds_Persian = 749, # D-sharp persian
    E_Persian = 856, # E persian
    F_Persian = 963, # F persian
    Fs_Persian = 1070, # F-sharp persian
    G_Persian = 1177, # G persian
    Gs_Persian = 1284, # G-sharp persian
    
    A_Enigmatic = 109, # A enigmatic
    As_Enigmatic = 218, # A-sharp enigmatic
    B_Enigmatic = 327, # B enigmatic
    C_Enigmatic = 436, # C enigmatic
    Cs_Enigmatic = 545, # C-sharp enigmatic
    D_Enigmatic = 654, # D enigmatic
    Ds_Enigmatic = 763, # D-sharp enigmatic
    E_Enigmatic = 872, # E enigmatic
    F_Enigmatic = 981, # F enigmatic
    Fs_Enigmatic = 1090, # F-sharp enigmatic
    G_Enigmatic = 1199, # G enigmatic
    Gs_Enigmatic = 1308, # G-sharp enigmatic
    
    A_Spanish_8_Tone = 113, # A spanish 8-tone (flamenco)
    As_Spanish_8_Tone = 226, # A-sharp spanish 8-tone (flamenco)
    B_Spanish_8_Tone = 339, # B spanish 8-tone (flamenco)
    C_Spanish_8_Tone = 452, # C spanish 8-tone (flamenco)
    Cs_Spanish_8_Tone = 565, # C-sharp spanish 8-tone (flamenco)
    D_Spanish_8_Tone = 678, # D spanish 8-tone (flamenco)
    Ds_Spanish_8_Tone = 791, # D-sharp spanish 8-tone (flamenco)
    E_Spanish_8_Tone = 904, # E spanish 8-tone (flamenco)
    F_Spanish_8_Tone = 1017, # F spanish 8-tone (flamenco)
    Fs_Spanish_8_Tone = 1130, # F-sharp spanish 8-tone (flamenco)
    G_Spanish_8_Tone = 1243, # G spanish 8-tone (flamenco)
    Gs_Spanish_8_Tone = 1356, # G-sharp spanish 8-tone (flamenco)
    
    A_Bebop_Major = 127, # A bebop major
    As_Bebop_Major = 254, # A-sharp bebop major
    B_Bebop_Major = 381, # B bebop major
    C_Bebop_Major = 508, # C bebop major
    Cs_Bebop_Major = 635, # C-sharp bebop major
    D_Bebop_Major = 762, # D bebop major
    Ds_Bebop_Major = 889, # D-sharp bebop major
    E_Bebop_Major = 1016, # E bebop major
    F_Bebop_Major = 1143, # F bebop major
    Fs_Bebop_Major = 1270, # F-sharp bebop major
    G_Bebop_Major = 1397, # G bebop major
    Gs_Bebop_Major = 1524, # G-sharp bebop major
    
    A_Bebop_Dorian = 131, # A bebop dorian
    As_Bebop_Dorian = 262, # A-sharp bebop dorian
    B_Bebop_Dorian = 393, # B bebop dorian
    C_Bebop_Dorian = 524, # C bebop dorian
    Cs_Bebop_Dorian = 655, # C-sharp bebop dorian
    D_Bebop_Dorian = 786, # D bebop dorian
    Ds_Bebop_Dorian = 917, # D-sharp bebop dorian
    E_Bebop_Dorian = 1048, # E bebop dorian
    F_Bebop_Dorian = 1179, # F bebop dorian
    Fs_Bebop_Dorian = 1310, # F-sharp bebop dorian
    G_Bebop_Dorian = 1441, # G bebop dorian
    Gs_Bebop_Dorian = 1572, # G-sharp bebop dorian
    
    A_Bebop_Mixolydian = 137, # A bebop mixolydian
    As_Bebop_Mixolydian = 274, # A-sharp bebop mixolydian
    B_Bebop_Mixolydian = 411, # B bebop mixolydian
    C_Bebop_Mixolydian = 548, # C bebop mixolydian
    Cs_Bebop_Mixolydian = 685, # C-sharp bebop mixolydian
    D_Bebop_Mixolydian = 822, # D bebop mixolydian
    Ds_Bebop_Mixolydian = 959, # D-sharp bebop mixolydian
    E_Bebop_Mixolydian = 1096, # E bebop mixolydian
    F_Bebop_Mixolydian = 1233, # F bebop mixolydian
    Fs_Bebop_Mixolydian = 1370, # F-sharp bebop mixolydian
    G_Bebop_Mixolydian = 1507, # G bebop mixolydian
    Gs_Bebop_Mixolydian = 1644, # G-sharp bebop mixolydian
    
    A_Bebop_Minor = 139, # A bebop minor (aeolian bebop)
    As_Bebop_Minor = 278, # A-sharp bebop minor (aeolian bebop)
    B_Bebop_Minor = 417, # B bebop minor (aeolian bebop)
    C_Bebop_Minor = 556, # C bebop minor (aeolian bebop)
    Cs_Bebop_Minor = 695, # C-sharp bebop minor (aeolian bebop)
    D_Bebop_Minor = 834, # D bebop minor (aeolian bebop)
    Ds_Bebop_Minor = 973, # D-sharp bebop minor (aeolian bebop)
    E_Bebop_Minor = 1112, # E bebop minor (aeolian bebop)
    F_Bebop_Minor = 1251, # F bebop minor (aeolian bebop)
    Fs_Bebop_Minor = 1390, # F-sharp bebop minor (aeolian bebop)
    G_Bebop_Minor = 1529, # G bebop minor (aeolian bebop)
    Gs_Bebop_Minor = 1668, # G-sharp bebop minor (aeolian bebop)
    
    A_Insen = 149, # A insen (Japanese)
    As_Insen = 298, # A-sharp insen (Japanese)
    B_Insen = 447, # B insen (Japanese)
    C_Insen = 596, # C insen (Japanese)
    Cs_Insen = 745, # C-sharp insen (Japanese)
    D_Insen = 894, # D insen (Japanese)
    Ds_Insen = 1043, # D-sharp insen (Japanese)
    E_Insen = 1192, # E insen (Japanese)
    F_Insen = 1341, # F insen (Japanese)
    Fs_Insen = 1490, # F-sharp insen (Japanese)
    G_Insen = 1639, # G insen (Japanese)
    Gs_Insen = 1788, # G-sharp insen (Japanese)
    
    A_Hirajoshi = 151, # A hirajoshi (Japanese)
    As_Hirajoshi = 302, # A-sharp hirajoshi (Japanese)
    B_Hirajoshi = 453, # B hirajoshi (Japanese)
    C_Hirajoshi = 604, # C hirajoshi (Japanese)
    Cs_Hirajoshi = 755, # C-sharp hirajoshi (Japanese)
    D_Hirajoshi = 906, # D hirajoshi (Japanese)
    Ds_Hirajoshi = 1057, # D-sharp hirajoshi (Japanese)
    E_Hirajoshi = 1208, # E hirajoshi (Japanese)
    F_Hirajoshi = 1359, # F hirajoshi (Japanese)
    Fs_Hirajoshi = 1510, # F-sharp hirajoshi (Japanese)
    G_Hirajoshi = 1661, # G hirajoshi (Japanese)
    Gs_Hirajoshi = 1812, # G-sharp hirajoshi (Japanese)
    
    A_Kumoi = 157, # A kumoi (Japanese)
    As_Kumoi = 314, # A-sharp kumoi (Japanese)
    B_Kumoi = 471, # B kumoi (Japanese)
    C_Kumoi = 628, # C kumoi (Japanese)
    Cs_Kumoi = 785, # C-sharp kumoi (Japanese)
    D_Kumoi = 942, # D kumoi (Japanese)
    Ds_Kumoi = 1099, # D-sharp kumoi (Japanese)
    E_Kumoi = 1256, # E kumoi (Japanese)
    F_Kumoi = 1413, # F kumoi (Japanese)
    Fs_Kumoi = 1570, # F-sharp kumoi (Japanese)
    G_Kumoi = 1727, # G kumoi (Japanese)
    Gs_Kumoi = 1884, # G-sharp kumoi (Japanese)
    
    A_Pelog = 163, # A pelog (Indonesian)
    As_Pelog = 326, # A-sharp pelog (Indonesian)
    B_Pelog = 489, # B pelog (Indonesian)
    C_Pelog = 652, # C pelog (Indonesian)
    Cs_Pelog = 815, # C-sharp pelog (Indonesian)
    D_Pelog = 978, # D pelog (Indonesian)
    Ds_Pelog = 1141, # D-sharp pelog (Indonesian)
    E_Pelog = 1304, # E pelog (Indonesian)
    F_Pelog = 1467, # F pelog (Indonesian)
    Fs_Pelog = 1630, # F-sharp pelog (Indonesian)
    G_Pelog = 1793, # G pelog (Indonesian)
    Gs_Pelog = 1956, # G-sharp pelog (Indonesian)
    
    A_Prometheus = 167, # A prometheus
    As_Prometheus = 334, # A-sharp prometheus
    B_Prometheus = 501, # B prometheus
    C_Prometheus = 668, # C prometheus
    Cs_Prometheus = 835, # C-sharp prometheus
    D_Prometheus = 1002, # D prometheus
    Ds_Prometheus = 1169, # D-sharp prometheus
    E_Prometheus = 1336, # E prometheus
    F_Prometheus = 1503, # F prometheus
    Fs_Prometheus = 1670, # F-sharp prometheus
    G_Prometheus = 1837, # G prometheus
    Gs_Prometheus = 2004, # G-sharp prometheus
    
    A_Ukrainian_Dorian = 173, # A ukrainian dorian (dorian #4)
    As_Ukrainian_Dorian = 346, # A-sharp ukrainian dorian (dorian #4)
    B_Ukrainian_Dorian = 519, # B ukrainian dorian (dorian #4)
    C_Ukrainian_Dorian = 692, # C ukrainian dorian (dorian #4)
    Cs_Ukrainian_Dorian = 865, # C-sharp ukrainian dorian (dorian #4)
    D_Ukrainian_Dorian = 1038, # D ukrainian dorian (dorian #4)
    Ds_Ukrainian_Dorian = 1211, # D-sharp ukrainian dorian (dorian #4)
    E_Ukrainian_Dorian = 1384, # E ukrainian dorian (dorian #4)
    F_Ukrainian_Dorian = 1557, # F ukrainian dorian (dorian #4)
    Fs_Ukrainian_Dorian = 1730, # F-sharp ukrainian dorian (dorian #4)
    G_Ukrainian_Dorian = 1903, # G ukrainian dorian (dorian #4)
    Gs_Ukrainian_Dorian = 2076, # G-sharp ukrainian dorian (dorian #4)
    
    A_Lydian_Augmented = 179, # A lydian augmented
    As_Lydian_Augmented = 358, # A-sharp lydian augmented
    B_Lydian_Augmented = 537, # B lydian augmented
    C_Lydian_Augmented = 716, # C lydian augmented
    Cs_Lydian_Augmented = 895, # C-sharp lydian augmented
    D_Lydian_Augmented = 1074, # D lydian augmented
    Ds_Lydian_Augmented = 1253, # D-sharp lydian augmented
    E_Lydian_Augmented = 1432, # E lydian augmented
    F_Lydian_Augmented = 1611, # F lydian augmented
    Fs_Lydian_Augmented = 1790, # F-sharp lydian augmented
    G_Lydian_Augmented = 1969, # G lydian augmented
    Gs_Lydian_Augmented = 2148, # G-sharp lydian augmented
    
    A_Lydian_Minor = 181, # A lydian minor
    As_Lydian_Minor = 362, # A-sharp lydian minor
    B_Lydian_Minor = 543, # B lydian minor
    C_Lydian_Minor = 724, # C lydian minor
    Cs_Lydian_Minor = 905, # C-sharp lydian minor
    D_Lydian_Minor = 1086, # D lydian minor
    Ds_Lydian_Minor = 1267, # D-sharp lydian minor
    E_Lydian_Minor = 1448, # E lydian minor
    F_Lydian_Minor = 1629, # F lydian minor
    Fs_Lydian_Minor = 1810, # F-sharp lydian minor
    G_Lydian_Minor = 1991, # G lydian minor
    Gs_Lydian_Minor = 2172, # G-sharp lydian minor
    
    A_Major_Locrian = 191, # A major locrian
    As_Major_Locrian = 382, # A-sharp major locrian
    B_Major_Locrian = 573, # B major locrian
    C_Major_Locrian = 764, # C major locrian
    Cs_Major_Locrian = 955, # C-sharp major locrian
    D_Major_Locrian = 1146, # D major locrian
    Ds_Major_Locrian = 1337, # D-sharp major locrian
    E_Major_Locrian = 1528, # E major locrian
    F_Major_Locrian = 1719, # F major locrian
    Fs_Major_Locrian = 1910, # F-sharp major locrian
    G_Major_Locrian = 2101, # G major locrian
    Gs_Major_Locrian = 2292, # G-sharp major locrian
    
    A_Half_Diminished = 197, # A half-diminished (locrian #2)
    As_Half_Diminished = 394, # A-sharp half-diminished (locrian #2)
    B_Half_Diminished = 591, # B half-diminished (locrian #2)
    C_Half_Diminished = 788, # C half-diminished (locrian #2)
    Cs_Half_Diminished = 985, # C-sharp half-diminished (locrian #2)
    D_Half_Diminished = 1182, # D half-diminished (locrian #2)
    Ds_Half_Diminished = 1379, # D-sharp half-diminished (locrian #2)
    E_Half_Diminished = 1576, # E half-diminished (locrian #2)
    F_Half_Diminished = 1773, # F half-diminished (locrian #2)
    Fs_Half_Diminished = 1970, # F-sharp half-diminished (locrian #2)
    G_Half_Diminished = 2167, # G half-diminished (locrian #2)
    Gs_Half_Diminished = 2364, # G-sharp half-diminished (locrian #2)
}


# Convert our Key Enum to a string
func Music_Key_to_String(Key_to_check : E_MUSIC_KEYS) -> String:
    var output := ""
    const notes :=      ['',    'A',    'A',    'B',    'C',    'C', 
                         'D',   'D',    'E',    'F',    'F',    'G',    'G']
    const is_sharp :=   [false, false,  true,   false,  false,  true, 
                        false,  true,   false,  false,  true,   false,  true]
    const prime_to_scale := {
        3: "Major",
        7: "Minor (Natural)",
        11: "Dorian",
        13: "Phrygian",
        17: "Lydian",
        19: "Mixolydian",
        23: "Locrian",
        29: "Minor (Harmonic)",
        31: "Minor (Melodic)",
        37: "Major (Pentatonic)",
        41: "Minor (Pentatonic)",
        43: "Minor (Blues)",
        47: "Major (Blues)",
        53: "Whole Tone",
        59: "Chromatic",
        61: "Diminished Whole-Half",
        67: "Diminished Half-Whole",
        71: "Altered",
        73: "Phrygian Dominant",
        79: "Lydian Dominant",
        83: "Minor (Neapolitan)",
        89: "Major (Neapolitan)",
        97: "Double Harmonic Major",
        101: "Minor (Hungarian)",
        103: "Major (Hungarian)",
        107: "Persian",
        109: "Enigmatic",
        113: "Spanish 8-Tone",
        127: "Major (Bebop)",
        131: "Dorian (Bebop)",
        137: "Mixolydian (Bebop)",
        139: "Minor (Bebop)",
        149: "Insen",
        151: "Hirajoshi",
        157: "Kumoi",
        163: "Pelog",
        167: "Prometheus",
        173: "Ukrainian Dorian",
        179: "Lydian Augmented",
        181: "Minor (Lydian)",
        191: "Major Locrian",
        197: "Half-Diminished",
        }
        
    # handle our special cases first
    var found_note := -1
    var found_scale := ""
    
    match Key_to_check:
        E_MUSIC_KEYS.Ds_Major:
            return "D# Major"
        E_MUSIC_KEYS.G_Major:
            return "G Major"
        E_MUSIC_KEYS.G_Natural_Minor:
            return "G Minor (Natural)"
        _:
            for prime in prime_to_scale.keys():
                if prime % Key_to_check != 0:
                    continue
                var current_note := int(Key_to_check / prime)
                if current_note >= 1 and current_note <= 12:
                    found_note = current_note
                    found_scale = prime_to_scale[prime]
                    break
        
    if found_note <= 0:
        return "Unknown"
        
    # Format's gonna be {note}{sharp?} {Scale}
    output += (notes[found_note] + "#") if is_sharp[found_note] else notes[found_note]
    
    output += " " + found_scale     
            
    return output


# Check that an int is actually a valid music key enum?
@export
func Is_Valid_Key(int_to_check : int) -> bool:
    return Music_Key_to_String(int_to_check) != "Unknown"



func Is_Valid_Key__TEST() -> bool:
    var great_success = true
    
    # Tests that SHOULD pass
    var test_1_Success := Is_Valid_Key(3)
    var test_2_Success := Is_Valid_Key(18)
    var test_3_Success := Is_Valid_Key(2)
    var test_4_Success := Is_Valid_Key(4)
    var test_5_Success := Is_Valid_Key(8)
    var test_6_Success := Is_Valid_Key(1164)
    var test_7_Success := Is_Valid_Key(179)
    
    # Tests that SHOULD fail
    var test_1_Fail := Is_Valid_Key(20)
    var test_2_Fail := Is_Valid_Key(180)
    var test_3_Fail := Is_Valid_Key(971)
    var test_4_Fail := Is_Valid_Key(-1)
    var test_5_Fail := Is_Valid_Key(0)
    var test_6_Fail := Is_Valid_Key(1)
    
    great_success = (   test_1_Success
                    and test_2_Success
                    and test_3_Success
                    and test_4_Success
                    and test_5_Success
                    and test_6_Success
                    and test_7_Success) and (test_1_Fail
                    and test_2_Fail
                    and test_3_Fail
                    and test_4_Fail
                    and test_5_Fail
                    and test_6_Fail)
    
    if great_success == false:
        printerr("Huge error with Is_Valid_Key()")    
        
    return great_success
    
