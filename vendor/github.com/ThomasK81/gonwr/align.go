package gonwr

func idx(i, j, blen int) int {
	return (i * blen) + j
}

// Align takes two Rune slices as well as three integers for the Needleman-Wunsch scoring function.
// It also takes a Rune that sets the filler character, e.g. rune('#')
// It returns the final score, as well as two aligned Rune slices.
func Align(a, b []rune, filler rune, match, mismatch, gap int) (runeSl1, runeSl2 []rune, score int) {
	a = append([]rune{rune(' ')}, a...)
	b = append([]rune{rune(' ')}, b...)
	alen := len(a)
	blen := len(b)
	matlen := alen * blen
	indexSl := make([]int, matlen)
	scoreSl := make([]int, matlen)
	rowcount := 1
	for i := 1; i < alen*blen; i++ {
		if i < blen {
			indexSl[i] = i - 1
			scoreSl[i] = gap * i
			continue
		}
		if i%blen == 0 {
			indexSl[i] = i - blen
			scoreSl[i] = gap * rowcount
			rowcount++
			continue
		}
		indexB := i % blen
		indexA := i / blen
		score := match
		if a[indexA] != b[indexB] {
			score = mismatch
		}
		left := score + scoreSl[i-1]
		up := score + scoreSl[i-blen]
		diag := score + scoreSl[i-(blen+1)]
		result := diag
		nextCell := i - (blen + 1)
		if diag < left {
			result = left
			nextCell = i - 1
			if left < up {
				result = up
				nextCell = i - blen
			}
		}
		if diag < up && diag >= left {
			result = up
			nextCell = i - blen
		}
		scoreSl[i] = result
		indexSl[i] = nextCell
	}
	path := []int{}
	start := (alen * blen) - 1
	score = scoreSl[start]
	for start != 0 {
		path = append(path, start)
		start = indexSl[start]
	}
	for i := len(path) - 1; i >= 0; i-- {
		indexA := path[i] / blen
		if indexA >= 0 && indexA < len(a) {
			runeSl1 = append(runeSl1, a[indexA])
			a[indexA] = filler
		}
		indexB := (path[i] % blen)
		if indexB >= 0 && indexB < len(b) {
			runeSl2 = append(runeSl2, b[indexB])
			b[indexB] = filler
		}
	}
	return runeSl1, runeSl2, score
}
