.PHONY: check render-rhoe-liquid-formula render-rhoe-markdown-formula render-rhoe-json-formula clean

check:
	bash Scripts/CI/validate-tap.sh

render-rhoe-liquid-formula:
	bash Scripts/CI/render-rhoe-liquid-formula.sh

render-rhoe-markdown-formula:
	bash Scripts/CI/render-rhoe-markdown-formula.sh

render-rhoe-json-formula:
	bash Scripts/CI/render-rhoe-json-formula.sh

clean:
	rm -f Formula/rhoe-liquid.rb Formula/rhoe-markdown.rb Formula/rhoe-json.rb
