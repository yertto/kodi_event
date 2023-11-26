export PATH := bin:$(PATH)
export uid := 1700610725

all: test

test:
	shpec
