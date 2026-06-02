.PHONY: check render-rhoe-liquid-formula clean

check:
	bash Scripts/CI/validate-tap.sh

render-rhoe-liquid-formula:
	bash Scripts/CI/render-rhoe-liquid-formula.sh

clean:
	rm -f Formula/rhoe-liquid.rb
