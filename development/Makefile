all:
	@ln -Fis "${CURDIR}/gitconfig" "${HOME}/.gitconfig"
	@grep -q '/zshrc' "${HOME}/.zshrc" 2> /dev/null || \
		echo "source '${CURDIR}/zshrc'" >> "${HOME}/.zshrc"