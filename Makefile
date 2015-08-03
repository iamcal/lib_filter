all:
	@echo "Future build step will go here";

test:
	@prove --exec 'php' t/*.t
