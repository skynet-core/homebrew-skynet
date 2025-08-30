default: reinstall-all

style TARGET:
    brew style ./Formula/{{ TARGET }}.rb

style-fix TARGET:
    brew style --fix ./Formula/{{ TARGET }}.rb

install TARGET:
    brew install --force --keep-tmp -s ./Formula/{{ TARGET }}.rb

remove TARGET:
    brew uninstall --force {{ TARGET }}

remove-all:
    for pkg in `tac packages.txt`; do \
        echo "Removing $pkg..."; \
        brew uninstall --force --ignore-dependencies $pkg || true; \
    done

install-all:
    for pkg in `cat packages.txt`; do \
        echo "Installing $pkg..."; \
        brew install --force --keep-tmp -s $pkg || true; \
    done

reinstall-all: remove-all install-all
