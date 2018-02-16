cd "$(dirname "${BASH_SOURCE}")";

find \
    "$(pwd)" \
    \! \( -name ".git" -type d -prune \) \
    \! \( -name "init" -type d -prune \) \
    \! -name ".DS_Store" \
    \! -name "bootstrap.sh" \
    \! -name "brew.sh" \
    \! -name "macos.sh" \
    \! -name "vim.sh" \
    \! -name "README.md" \
    -type d -print

cat <<EOF | mapfile
1
2
3
4
a
b
c
EOF

echo ${MAPFILE}


    # \( -type d -exec echo "want to make dir {}" \; \) -o \
    # \( -type f -exec echo "want to symlink file {}" \; \) \


exit

rsync --exclude "/.git/" \
    --exclude ".DS_Store" \
    --exclude "/bootstrap.sh" \
    --exclude "/brew.sh" \
    --exclude "/macos.sh" \
    --exclude "/vim.sh" \
    --exclude "/init/" \
    --exclude "/README.md" \
    --archive \
    --verbose \
    --human-readable \
    --no-perms . ~;
