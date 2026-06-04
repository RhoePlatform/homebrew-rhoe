.PHONY: check render-rhoe-liquid-formula render-rhoe-markdown-formula clean

check:
	bash Scripts/CI/validate-tap.sh

render-rhoe-liquid-formula:
	bash Scripts/CI/render-rhoe-liquid-formula.sh

render-rhoe-markdown-formula:
	bash Scripts/CI/render-rhoe-markdown-formula.sh

clean:
	rm -f Formula/rhoe-liquid.rb Formula/rhoe-markdown.rb
