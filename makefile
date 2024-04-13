.PHONY: build run kill test

n=100
p=10

all: build run

test:
	seq 1 $n | xargs -P $p -I{} curl -s http://localhost:3000/path{} 1> /dev/null
build:
	docker build -t shiny .
run:
	docker run --rm -p 3000:3000 --name shiny shiny
kill:
	docker kill shiny
