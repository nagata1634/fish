# ASDF設定
function asdf_conf
        if test -z $ASDF_DATA_DIR
                set _asdf_shims $HOME/.asdf/shims
        else
                set _asdf_shims $ASDF_DATA_DIR/shims
        end

        if not contains $_asdf_shims $PATH
                set -gx --prepend PATH $_asdf_shims
        end
        set --erase _asdf_shims
end

# Neovim 
function nvim --wraps=nvim
        if set -q NVIM
                nvr $argv 2>/dev/null
        else
                command nvim +term
        end
end
# 対話セッション時の処理
if status is-interactive
        asdf_conf
        fish_add_path $HOME/.local/bin
        if not set -q NVIM ; and not test "$TERM_PROGRAM" = "vscode"
                nvim +term
        end
end