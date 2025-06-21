# 環境変数セット
function environment
    # ASDF
    set -x ASDF_DATA_DIR $HOME/.config/asdf
    # Node
    set -x NPM_CONFIG_PREFIX $HOME/.local
    # Local binary
    fish_add_path $HOME/.local/bin

    # Fish log
    set -x FISH_LOG $HOME/.local/state/fish/logs
    if not test -d $FISH_LOG 
        mkdir -p $FISH_LOG
    end
    if not test -e $FISH_LOG/startup.log
        touch $FISH_LOG/startup.log
    else
        echo "" > $FISH_LOG/startup.log
    end
end

# ログ関数
function log
    echo "$argv" >> $FISH_LOG/startup.log
end

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

# Nvimを起動（NVIM環境変数が未定義なら）
function nvim_open
    if set -q NVIM
        log '環境変数$NVIMは設定されています'
    else
        nvim +terminal
    end
end

# Neovim 
function nvim --wraps=nvim
    if test -z "$NVIM"
        command nvim $argv
    else
        if contains -o $argv

            set first $argv[1]
            set rest $argv[2..-1]

            nvr $first
            for f in $rest
                nvr -c "split $f"
            end
        else if contains -O $argv
            set index (contains -i -O $argv)
            set -e argv[$index]  # -O を削除

            set first $argv[1]
            set rest $argv[2..-1]

            nvr $first
            for f in $rest
                nvr -c "vsplit $f"
            end
        else if contains -d $argv
            set index (contains -i -d $argv)
            set -e argv[$index]

            set first $argv[1]
            set rest $argv[2..-1]

            nvr $first

            for f in $rest
                nvr -c "vsplit $f | diffthis"
            end

        else if contains -b $argv
            set index (contains -i -b $argv)
            set -e argv[$index]

            for f in $index
                nvr -c "edit $f | set binary"
            end
        else
            nvr $argv
        end
    end
end
# 対話セッション時の処理
if status is-interactive
    echo "" > $FISH_LOG/startup.log
    echo "$env" > $FISH_LOG/startup.log
    environment
    asdf_conf
    nvim_open
end
