style TARGET:
    brew style ./Formula/{{ TARGET }}.rb

style-fix TARGET:
    brew style --fix ./Formula/{{ TARGET }}.rb

install TARGET:
    brew install --force --keep-tmp -s ./Formula/{{ TARGET }}.rb
