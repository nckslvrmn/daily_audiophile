.PHONY: all clean function layer

all : clean function layer

function:
	find . -type d -name "__pycache__" -prune -exec rm -rf {} \;
	zip function.zip lambda.py config.yaml template.html.j2

layer:
	find . -type d -name "__pycache__" -prune -exec rm -rf {} \;
	docker run --rm -v `pwd`:/var/task --user `id -u`:`id -g` "public.ecr.aws/sam/build-python3.9:latest" /bin/sh -c "pip install --no-cache -r requirements.txt -t python; exit"
	zip -r ./layer.zip python/

clean:
	rm -rf python/ function.zip layer.zip index.html
	find . -type d -name "__pycache__" -prune -exec rm -rf {} \;
