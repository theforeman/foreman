.PHONY: all clean container_image html open

all: html

clean:
	rm -f index.html

container_image:
	podman build --tag developer_docs --file Containerfile .

html:
	podman run --rm -v $$(pwd):/developer_docs:Z developer_docs asciidoctor index.adoc

open:
	xdg-open index.html
