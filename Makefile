export PATH := bin:$(PATH)

all: test

test:
	shpec
