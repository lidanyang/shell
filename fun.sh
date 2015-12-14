__all_modules () 
{ 
    while read name; do
        name=${name%% *};
        printf "%s\n" "$name";
    done < <(pulseaudio --dump-modules 2> /dev/null)
}
__cards () 
{ 
    while IFS='	' read idx name _; do
        printf "%s %s\n" "$idx" "$name";
    done < <(pactl list cards short 2> /dev/null)
}
__expand_tilde_by_ref () 
{ 
    if [[ ${!1} == \~* ]]; then
        if [[ ${!1} == */* ]]; then
            eval $1="${!1/%\/*}"/'${!1#*/}';
        else
            eval $1="${!1}";
        fi;
    fi
}
__get_cword_at_cursor_by_ref () 
{ 
    local cword words=();
    __reassemble_comp_words_by_ref "$1" words cword;
    local i cur index=$COMP_POINT lead=${COMP_LINE:0:$COMP_POINT};
    if [[ $index -gt 0 && ( -n $lead && -n ${lead//[[:space:]]} ) ]]; then
        cur=$COMP_LINE;
        for ((i = 0; i <= cword; ++i ))
        do
            while [[ ${#cur} -ge ${#words[i]} && "${cur:0:${#words[i]}}" != "${words[i]}" ]]; do
                cur="${cur:1}";
                ((index--));
            done;
            if [[ $i -lt $cword ]]; then
                local old_size=${#cur};
                cur="${cur#"${words[i]}"}";
                local new_size=${#cur};
                index=$(( index - old_size + new_size ));
            fi;
        done;
        [[ -n $cur && ! -n ${cur//[[:space:]]} ]] && cur=;
        [[ $index -lt 0 ]] && index=0;
    fi;
    local "$2" "$3" "$4" && _upvars -a${#words[@]} $2 "${words[@]}" -v $3 "$cword" -v $4 "${cur:0:$index}"
}
__git_ps1 () 
{ 
    local pcmode=no;
    local detached=no;
    local ps1pc_start='\u@\h:\w ';
    local ps1pc_end='\$ ';
    local printf_format=' (%s)';
    case "$#" in 
        2 | 3)
            pcmode=yes;
            ps1pc_start="$1";
            ps1pc_end="$2";
            printf_format="${3:-$printf_format}"
        ;;
        0 | 1)
            printf_format="${1:-$printf_format}"
        ;;
        *)
            return
        ;;
    esac;
    local repo_info rev_parse_exit_code;
    repo_info="$(git rev-parse --git-dir --is-inside-git-dir 		--is-bare-repository --is-inside-work-tree 		--short HEAD 2>/dev/null)";
    rev_parse_exit_code="$?";
    if [ -z "$repo_info" ]; then
        if [ $pcmode = yes ]; then
            PS1="$ps1pc_start$ps1pc_end";
        fi;
        return;
    fi;
    local short_sha;
    if [ "$rev_parse_exit_code" = "0" ]; then
        short_sha="${repo_info##*
}";
        repo_info="${repo_info%
*}";
    fi;
    local inside_worktree="${repo_info##*
}";
    repo_info="${repo_info%
*}";
    local bare_repo="${repo_info##*
}";
    repo_info="${repo_info%
*}";
    local inside_gitdir="${repo_info##*
}";
    local g="${repo_info%
*}";
    local r="";
    local b="";
    local step="";
    local total="";
    if [ -d "$g/rebase-merge" ]; then
        read b 2> /dev/null < "$g/rebase-merge/head-name";
        read step 2> /dev/null < "$g/rebase-merge/msgnum";
        read total 2> /dev/null < "$g/rebase-merge/end";
        if [ -f "$g/rebase-merge/interactive" ]; then
            r="|REBASE-i";
        else
            r="|REBASE-m";
        fi;
    else
        if [ -d "$g/rebase-apply" ]; then
            read step 2> /dev/null < "$g/rebase-apply/next";
            read total 2> /dev/null < "$g/rebase-apply/last";
            if [ -f "$g/rebase-apply/rebasing" ]; then
                read b 2> /dev/null < "$g/rebase-apply/head-name";
                r="|REBASE";
            else
                if [ -f "$g/rebase-apply/applying" ]; then
                    r="|AM";
                else
                    r="|AM/REBASE";
                fi;
            fi;
        else
            if [ -f "$g/MERGE_HEAD" ]; then
                r="|MERGING";
            else
                if [ -f "$g/CHERRY_PICK_HEAD" ]; then
                    r="|CHERRY-PICKING";
                else
                    if [ -f "$g/REVERT_HEAD" ]; then
                        r="|REVERTING";
                    else
                        if [ -f "$g/BISECT_LOG" ]; then
                            r="|BISECTING";
                        fi;
                    fi;
                fi;
            fi;
        fi;
        if [ -n "$b" ]; then
            :;
        else
            if [ -h "$g/HEAD" ]; then
                b="$(git symbolic-ref HEAD 2>/dev/null)";
            else
                local head="";
                if ! read head 2> /dev/null < "$g/HEAD"; then
                    if [ $pcmode = yes ]; then
                        PS1="$ps1pc_start$ps1pc_end";
                    fi;
                    return;
                fi;
                b="${head#ref: }";
                if [ "$head" = "$b" ]; then
                    detached=yes;
                    b="$(
				case "${GIT_PS1_DESCRIBE_STYLE-}" in
				(contains)
					git describe --contains HEAD ;;
				(branch)
					git describe --contains --all HEAD ;;
				(describe)
					git describe HEAD ;;
				(* | default)
					git describe --tags --exact-match HEAD ;;
				esac 2>/dev/null)" || b="$short_sha...";
                    b="($b)";
                fi;
            fi;
        fi;
    fi;
    if [ -n "$step" ] && [ -n "$total" ]; then
        r="$r $step/$total";
    fi;
    local w="";
    local i="";
    local s="";
    local u="";
    local c="";
    local p="";
    if [ "true" = "$inside_gitdir" ]; then
        if [ "true" = "$bare_repo" ]; then
            c="BARE:";
        else
            b="GIT_DIR!";
        fi;
    else
        if [ "true" = "$inside_worktree" ]; then
            if [ -n "${GIT_PS1_SHOWDIRTYSTATE-}" ] && [ "$(git config --bool bash.showDirtyState)" != "false" ]; then
                git diff --no-ext-diff --quiet --exit-code || w="*";
                if [ -n "$short_sha" ]; then
                    git diff-index --cached --quiet HEAD -- || i="+";
                else
                    i="#";
                fi;
            fi;
            if [ -n "${GIT_PS1_SHOWSTASHSTATE-}" ] && [ -r "$g/refs/stash" ]; then
                s="$";
            fi;
            if [ -n "${GIT_PS1_SHOWUNTRACKEDFILES-}" ] && [ "$(git config --bool bash.showUntrackedFiles)" != "false" ] && git ls-files --others --exclude-standard --error-unmatch -- '*' > /dev/null 2> /dev/null; then
                u="%${ZSH_VERSION+%}";
            fi;
            if [ -n "${GIT_PS1_SHOWUPSTREAM-}" ]; then
                __git_ps1_show_upstream;
            fi;
        fi;
    fi;
    local z="${GIT_PS1_STATESEPARATOR-" "}";
    if [ $pcmode = yes ] && [ -n "${GIT_PS1_SHOWCOLORHINTS-}" ]; then
        __git_ps1_colorize_gitstring;
    fi;
    local f="$w$i$s$u";
    local gitstring="$c${b##refs/heads/}${f:+$z$f}$r$p";
    if [ $pcmode = yes ]; then
        if [ "${__git_printf_supports_v-}" != yes ]; then
            gitstring=$(printf -- "$printf_format" "$gitstring");
        else
            printf -v gitstring -- "$printf_format" "$gitstring";
        fi;
        PS1="$ps1pc_start$gitstring$ps1pc_end";
    else
        printf -- "$printf_format" "$gitstring";
    fi
}
__git_ps1_colorize_gitstring () 
{ 
    if [[ -n ${ZSH_VERSION-} ]]; then
        local c_red='%F{red}';
        local c_green='%F{green}';
        local c_lblue='%F{blue}';
        local c_clear='%f';
    else
        local c_red='\[\e[31m\]';
        local c_green='\[\e[32m\]';
        local c_lblue='\[\e[1;34m\]';
        local c_clear='\[\e[0m\]';
    fi;
    local bad_color=$c_red;
    local ok_color=$c_green;
    local flags_color="$c_lblue";
    local branch_color="";
    if [ $detached = no ]; then
        branch_color="$ok_color";
    else
        branch_color="$bad_color";
    fi;
    c="$branch_color$c";
    z="$c_clear$z";
    if [ "$w" = "*" ]; then
        w="$bad_color$w";
    fi;
    if [ -n "$i" ]; then
        i="$ok_color$i";
    fi;
    if [ -n "$s" ]; then
        s="$flags_color$s";
    fi;
    if [ -n "$u" ]; then
        u="$bad_color$u";
    fi;
    r="$c_clear$r"
}
__git_ps1_show_upstream () 
{ 
    local key value;
    local svn_remote svn_url_pattern count n;
    local upstream=git legacy="" verbose="" name="";
    svn_remote=();
    local output="$(git config -z --get-regexp '^(svn-remote\..*\.url|bash\.showupstream)$' 2>/dev/null | tr '\0\n' '\n ')";
    while read -r key value; do
        case "$key" in 
            bash.showupstream)
                GIT_PS1_SHOWUPSTREAM="$value";
                if [[ -z "${GIT_PS1_SHOWUPSTREAM}" ]]; then
                    p="";
                    return;
                fi
            ;;
            svn-remote.*.url)
                svn_remote[$((${#svn_remote[@]} + 1))]="$value";
                svn_url_pattern="$svn_url_pattern\\|$value";
                upstream=svn+git
            ;;
        esac;
    done <<< "$output";
    for option in ${GIT_PS1_SHOWUPSTREAM};
    do
        case "$option" in 
            git | svn)
                upstream="$option"
            ;;
            verbose)
                verbose=1
            ;;
            legacy)
                legacy=1
            ;;
            name)
                name=1
            ;;
        esac;
    done;
    case "$upstream" in 
        git)
            upstream="@{upstream}"
        ;;
        svn*)
            local -a svn_upstream;
            svn_upstream=($(git log --first-parent -1 					--grep="^git-svn-id: \(${svn_url_pattern#??}\)" 2>/dev/null));
            if [[ 0 -ne ${#svn_upstream[@]} ]]; then
                svn_upstream=${svn_upstream[${#svn_upstream[@]} - 2]};
                svn_upstream=${svn_upstream%@*};
                local n_stop="${#svn_remote[@]}";
                for ((n=1; n <= n_stop; n++))
                do
                    svn_upstream=${svn_upstream#${svn_remote[$n]}};
                done;
                if [[ -z "$svn_upstream" ]]; then
                    upstream=${GIT_SVN_ID:-git-svn};
                else
                    upstream=${svn_upstream#/};
                fi;
            else
                if [[ "svn+git" = "$upstream" ]]; then
                    upstream="@{upstream}";
                fi;
            fi
        ;;
    esac;
    if [[ -z "$legacy" ]]; then
        count="$(git rev-list --count --left-right 				"$upstream"...HEAD 2>/dev/null)";
    else
        local commits;
        if commits="$(git rev-list --left-right "$upstream"...HEAD 2>/dev/null)"; then
            local commit behind=0 ahead=0;
            for commit in $commits;
            do
                case "$commit" in 
                    "<"*)
                        ((behind++))
                    ;;
                    *)
                        ((ahead++))
                    ;;
                esac;
            done;
            count="$behind	$ahead";
        else
            count="";
        fi;
    fi;
    if [[ -z "$verbose" ]]; then
        case "$count" in 
            "")
                p=""
            ;;
            "0	0")
                p="="
            ;;
            "0	"*)
                p=">"
            ;;
            *"	0")
                p="<"
            ;;
            *)
                p="<>"
            ;;
        esac;
    else
        case "$count" in 
            "")
                p=""
            ;;
            "0	0")
                p=" u="
            ;;
            "0	"*)
                p=" u+${count#0	}"
            ;;
            *"	0")
                p=" u-${count%	0}"
            ;;
            *)
                p=" u+${count#*	}-${count%	*}"
            ;;
        esac;
        if [[ -n "$count" && -n "$name" ]]; then
            p="$p $(git rev-parse --abbrev-ref "$upstream" 2>/dev/null)";
        fi;
    fi
}
__grub_dir () 
{ 
    local i c=1 boot_dir;
    for ((c=1; c <= ${#COMP_WORDS[@]}; c++ ))
    do
        i="${COMP_WORDS[c]}";
        case "$i" in 
            --boot-directory)
                c=$((++c));
                i="${COMP_WORDS[c]}";
                boot_dir="${i##*=}";
                break
            ;;
        esac;
    done;
    boot_dir=${boot_dir-/boot};
    echo "${boot_dir%/}/grub"
}
__grub_get_last_option () 
{ 
    local i;
    for ((i=$COMP_CWORD-1; i > 0; i-- ))
    do
        if [[ "${COMP_WORDS[i]}" == -* ]]; then
            echo "${COMP_WORDS[i]}";
            break;
        fi;
    done
}
__grub_get_options_from_help () 
{ 
    local prog;
    if [ $# -ge 1 ]; then
        prog="$1";
    else
        prog="${COMP_WORDS[0]}";
    fi;
    local i IFS=" "'	''
';
    for i in $(LC_ALL=C $prog --help);
    do
        case $i in 
            --*)
                echo "${i%=*}"
            ;;
        esac;
    done
}
__grub_get_options_from_usage () 
{ 
    local prog;
    if [ $# -ge 1 ]; then
        prog="$1";
    else
        prog="${COMP_WORDS[0]}";
    fi;
    local i IFS=" "'	''
';
    for i in $(LC_ALL=C $prog --usage);
    do
        case $i in 
            \[--*\])
                i=${i#[};
                echo ${i%%?(=*)]}
            ;;
        esac;
    done
}
__grub_list_menuentries () 
{ 
    local cur="${COMP_WORDS[COMP_CWORD]}";
    local config_file=$(__grub_dir)/grub.cfg;
    if [ -f "$config_file" ]; then
        local IFS='
';
        COMPREPLY=($(compgen             -W "$( awk -F "[\"']" '/menuentry/ { print $2 }' $config_file )"             -- "$cur" ));
    fi
}
__grub_list_modules () 
{ 
    local grub_dir=$(__grub_dir);
    local IFS='
';
    COMPREPLY=($( compgen -f -X '!*/*.mod' -- "${grub_dir}/$cur" | {
         while read -r tmp; do
             [ -n $tmp ] && {
                 tmp=${tmp##*/}
                 printf '%s\n' ${tmp%.mod}
             }
         done
         }
        ))
}
__grubcomp () 
{ 
    local cur="${COMP_WORDS[COMP_CWORD]}";
    if [ $# -gt 2 ]; then
        cur="$3";
    fi;
    case "$cur" in 
        --*=)
            COMPREPLY=()
        ;;
        *)
            local IFS=' ''	''
';
            COMPREPLY=($(compgen -P "${2-}" -W "${1-}" -S "${4-}" -- "$cur"))
        ;;
    esac
}
__loaded_modules () 
{ 
    while IFS='	' read idx name _; do
        printf "%s %s\n" "$idx" "$name";
    done < <(pactl list modules short 2> /dev/null)
}
__ltrim_colon_completions () 
{ 
    if [[ "$1" == *:* && "$COMP_WORDBREAKS" == *:* ]]; then
        local colon_word=${1%"${1##*:}"};
        local i=${#COMPREPLY[*]};
        while [[ $((--i)) -ge 0 ]]; do
            COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"};
        done;
    fi
}
__parse_options () 
{ 
    local option option2 i IFS=' 	
,/|';
    option=;
    for i in $1;
    do
        case $i in 
            ---*)
                break
            ;;
            --?*)
                option=$i;
                break
            ;;
            -?*)
                [[ -n $option ]] || option=$i
            ;;
            *)
                break
            ;;
        esac;
    done;
    [[ -n $option ]] || return 0;
    IFS=' 	
';
    if [[ $option =~ (\[((no|dont)-?)\]). ]]; then
        option2=${option/"${BASH_REMATCH[1]}"/};
        option2=${option2%%[<{().[]*};
        printf '%s\n' "${option2/=*/=}";
        option=${option/"${BASH_REMATCH[1]}"/"${BASH_REMATCH[2]}"};
    fi;
    option=${option%%[<{().[]*};
    printf '%s\n' "${option/=*/=}"
}
__ports () 
{ 
    pactl list cards 2> /dev/null | awk -e '/^\tPorts:/ {
            flag=1; next
         }

         /^\t[A-Za-z]/ {
             flag=0
         }

         flag {
             if (/^\t\t[A-Za-z]/)
                 ports = ports substr($0, 3, index($0, ":")-3) " "
         }

         END {
             print ports
         }'
}
__profiles () 
{ 
    pactl list cards 2> /dev/null | awk -e '/^\tProfiles:/ {
            flag=1; next
        }

        /^\t[A-Za-z]/ {
            flag=0
        }

        flag {
            if (/^\t\t[A-Za-z]/)
                profiles = profiles substr($0, 3, index($0, ": ")-3) " "
        }

        END {
            print profiles
        }'
}
__reassemble_comp_words_by_ref () 
{ 
    local exclude i j line ref;
    if [[ -n $1 ]]; then
        exclude="${1//[^$COMP_WORDBREAKS]}";
    fi;
    eval $3=$COMP_CWORD;
    if [[ -n $exclude ]]; then
        line=$COMP_LINE;
        for ((i=0, j=0; i < ${#COMP_WORDS[@]}; i++, j++))
        do
            while [[ $i -gt 0 && ${COMP_WORDS[$i]} == +([$exclude]) ]]; do
                [[ $line != [' 	']* ]] && (( j >= 2 )) && ((j--));
                ref="$2[$j]";
                eval $2[$j]=\${!ref}\${COMP_WORDS[i]};
                [[ $i == $COMP_CWORD ]] && eval $3=$j;
                line=${line#*"${COMP_WORDS[$i]}"};
                [[ $line == [' 	']* ]] && ((j++));
                (( $i < ${#COMP_WORDS[@]} - 1)) && ((i++)) || break 2;
            done;
            ref="$2[$j]";
            eval $2[$j]=\${!ref}\${COMP_WORDS[i]};
            line=${line#*"${COMP_WORDS[i]}"};
            [[ $i == $COMP_CWORD ]] && eval $3=$j;
        done;
        [[ $i == $COMP_CWORD ]] && eval $3=$j;
    else
        eval $2=\( \"\${COMP_WORDS[@]}\" \);
    fi
}
__resample_methods () 
{ 
    while read name; do
        printf "%s\n" "$name";
    done < <(pulseaudio --dump-resample-methods 2> /dev/null)
}
__sink_inputs () 
{ 
    while IFS='	' read idx _ _ _ _; do
        printf "%s\n" "$idx";
    done < <(pactl list sink-inputs short 2> /dev/null)
}
__sinks () 
{ 
    while IFS='	' read _ name _ _ _; do
        printf "%s\n" "$name";
    done < <(pactl list sinks short 2> /dev/null)
}
__sinks_idx () 
{ 
    while IFS='	' read idx _ _ _ _; do
        printf "%s\n" "$idx";
    done < <(pactl list sinks short 2> /dev/null)
}
__source_outputs () 
{ 
    while IFS='	' read idx _ _ _ _; do
        printf "%s\n" "$idx";
    done < <(pactl list source-outputs short 2> /dev/null)
}
__sources () 
{ 
    while IFS='	' read _ name _ _ _; do
        printf "%s\n" "$name";
    done < <(pactl list sources short 2> /dev/null)
}
_allowed_groups () 
{ 
    if _complete_as_root; then
        local IFS='
';
        COMPREPLY=($( compgen -g -- "$1" ));
    else
        local IFS='
 ';
        COMPREPLY=($( compgen -W             "$( id -Gn 2>/dev/null || groups 2>/dev/null )" -- "$1" ));
    fi
}
_allowed_users () 
{ 
    if _complete_as_root; then
        local IFS='
';
        COMPREPLY=($( compgen -u -- "${1:-$cur}" ));
    else
        local IFS='
 ';
        COMPREPLY=($( compgen -W             "$( id -un 2>/dev/null || whoami 2>/dev/null )" -- "${1:-$cur}" ));
    fi
}
_apport-bug () 
{ 
    local cur dashoptions prev param;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    dashoptions='-h --help --save -v --version --tag -w --window';
    case "$prev" in 
        ubuntu-bug | apport-bug)
            case "$cur" in 
                -*)
                    COMPREPLY=($( compgen -W "$dashoptions" -- $cur ))
                ;;
                *)
                    _apport_parameterless
                ;;
            esac
        ;;
        --save)
            COMPREPLY=($( compgen -o default -G "$cur*" ))
        ;;
        -w | --window)
            dashoptions="--save --tag";
            COMPREPLY=($( compgen -W "$dashoptions" -- $cur ))
        ;;
        -h | --help | -v | --version | --tag)
            return 0
        ;;
        *)
            dashoptions="--tag";
            if ! [[ "${COMP_WORDS[*]}" =~ .*--save.* ]]; then
                dashoptions="--save $dashoptions";
            fi;
            if ! [[ "${COMP_WORDS[*]}" =~ .*--window.* || "${COMP_WORDS[*]}" =~ .*\ -w\ .* ]]; then
                dashoptions="-w --window $dashoptions";
            fi;
            case "$cur" in 
                -*)
                    COMPREPLY=($( compgen -W "$dashoptions" -- $cur ))
                ;;
                *)
                    _apport_parameterless
                ;;
            esac
        ;;
    esac
}
_apport-cli () 
{ 
    local cur dashoptions prev param;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    dashoptions='-h --help -f --file-bug -u --update-bug -s --symptom \
                 -c --crash-file --save -v --version --tag -w --window';
    case "$prev" in 
        apport-cli)
            case "$cur" in 
                -*)
                    COMPREPLY=($( compgen -W "$dashoptions" -- $cur ))
                ;;
                *)
                    _apport_parameterless
                ;;
            esac
        ;;
        -f | --file-bug)
            param="-P --pid -p --package -s --symptom";
            COMPREPLY=($( compgen -W "$param $(_apport_symptoms)" -- $cur))
        ;;
        -s | --symptom)
            COMPREPLY=($( compgen -W "$(_apport_symptoms)" -- $cur))
        ;;
        --save)
            COMPREPLY=($( compgen -o default -G "$cur*" ))
        ;;
        -c | --crash-file)
            COMPREPLY=($( compgen -G "${cur}*.apport"
                       compgen -G "${cur}*.crash" ))
        ;;
        -w | --window)
            dashoptions="--save --tag";
            COMPREPLY=($( compgen -W "$dashoptions" -- $cur ))
        ;;
        -h | --help | -v | --version | --tag)
            return 0
        ;;
        *)
            dashoptions='--tag';
            if ! [[ "${COMP_WORDS[*]}" =~ .*--save.* ]]; then
                dashoptions="--save $dashoptions";
            fi;
            if ! [[ "${COMP_WORDS[*]}" =~ .*--window.* || "${COMP_WORDS[*]}" =~ .*\ -w\ .* ]]; then
                dashoptions="-w --window $dashoptions";
            fi;
            if ! [[ "${COMP_WORDS[*]}" =~ .*--symptom.* || "${COMP_WORDS[*]}" =~ .*\ -s\ .* ]]; then
                dashoptions="-s --symptom $dashoptions";
            fi;
            if ! [[ "${COMP_WORDS[*]}" =~ .*--update.* || "${COMP_WORDS[*]}" =~ .*\ -u\ .* ]]; then
                dashoptions="-u --update $dashoptions";
            fi;
            if ! [[ "${COMP_WORDS[*]}" =~ .*--file-bug.* || "${COMP_WORDS[*]}" =~ .*\ -f\ .* ]]; then
                dashoptions="-f --file-bug $dashoptions";
            fi;
            if ! [[ "${COMP_WORDS[*]}" =~ .*--crash-file.* || "${COMP_WORDS[*]}" =~ .*\ -c\ .* ]]; then
                dashoptions="-c --crash-file $dashoptions";
            fi;
            case "$cur" in 
                -*)
                    COMPREPLY=($( compgen -W "$dashoptions" -- $cur ))
                ;;
                *)
                    _apport_parameterless
                ;;
            esac
        ;;
    esac
}
_apport-collect () 
{ 
    local cur prev;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    case "$prev" in 
        apport-collect)
            COMPREPLY=($( compgen -W "-p --package --tag" -- $cur))
        ;;
        -p | --package)
            COMPREPLY=($( apt-cache pkgnames $cur 2> /dev/null ))
        ;;
        --tag)
            return 0
        ;;
        *)
            if [[ "${COMP_WORDS[*]}" =~ .*\ -p.* || "${COMP_WORDS[*]}" =~ .*--package.* ]]; then
                COMPREPLY=($( compgen -W "--tag" -- $cur));
            else
                COMPREPLY=($( compgen -W "-p --package --tag" -- $cur));
            fi
        ;;
    esac
}
_apport-unpack () 
{ 
    local cur prev;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    case "$prev" in 
        apport-unpack)
            COMPREPLY=($( compgen -G "${cur}*.apport"
                       compgen -G "${cur}*.crash" ))
        ;;
    esac
}
_apport_parameterless () 
{ 
    local param;
    param="$dashoptions            $( apt-cache pkgnames $cur 2> /dev/null )            $( command ps axo pid | sed 1d )            $( _apport_symptoms )            $( compgen -G "${cur}*" )";
    COMPREPLY=($( compgen -W "$param" -- $cur))
}
_apport_symptoms () 
{ 
    local syms;
    if [ -r /usr/share/apport/symptoms ]; then
        for FILE in $(ls /usr/share/apport/symptoms);
        do
            if [[ ! "$FILE" =~ ^_.* && -n $(egrep "^def run\s*\(.*\):" /usr/share/apport/symptoms/$FILE) ]]; then
                syms="$syms ${FILE%.py}";
            fi;
        done;
    fi;
    echo $syms
}
_available_interfaces () 
{ 
    local cmd PATH=$PATH:/sbin;
    if [[ ${1:-} == -w ]]; then
        cmd="iwconfig";
    else
        if [[ ${1:-} == -a ]]; then
            cmd="{ ifconfig || ip link show up; }";
        else
            cmd="{ ifconfig -a || ip link show; }";
        fi;
    fi;
    COMPREPLY=($( eval $cmd 2>/dev/null | awk         '/^[^ \t]/ { if ($1 ~ /^[0-9]+:/) { print $2 } else { print $1 } }' ));
    COMPREPLY=($( compgen -W '${COMPREPLY[@]/%[[:punct:]]/}' -- "$cur" ))
}
_axi_cache () 
{ 
    local cur prev cmd;
    COMPREPLY=();
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:};
    type _get_comp_words_by_ref &> /dev/null && { 
        _get_comp_words_by_ref -n: cur prev
    } || { 
        cur=$(_get_cword ":");
        prev=${COMP_WORDS[$COMP_CWORD-1]}
    };
    cmd=${COMP_WORDS[1]};
    case "$prev" in 
        *axi-cache*)
            COMPREPLY=($(compgen -W "help more search show again showpkg showsrc depends rdepends policy madison" -- "$cur"));
            return 0
        ;;
        --sort)
            COMPREPLY=($(compgen -W "$(egrep ^[a-z] /var/lib/apt-xapian-index/values | awk -F"\t" '{print $1}')" -- "$cur"));
            return 0
        ;;
    esac;
    case "$cmd" in 
        search | again)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--sort --tags" -- "$cur"));
                return 0;
            fi
        ;;
        show | showpkg | showsrc | depends | rdepends | policy | madison)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--last" -- "$cur"));
                return 0;
            fi
        ;;
        *)
            return 0
        ;;
    esac;
    if [ -n "$cur" ]; then
        COMPREPLY=($(compgen -W "$(${COMP_WORDS[@]} --tabcomplete=partial)" -- "$cur"));
    else
        COMPREPLY=($(compgen -W "$(${COMP_WORDS[@]} --tabcomplete=plain)" -- "$cur"));
    fi;
    return 0
}
_cd () 
{ 
    local cur prev words cword;
    _init_completion || return;
    local IFS='
' i j k;
    compopt -o filenames;
    if [[ -z "${CDPATH:-}" || "$cur" == ?(.)?(.)/* ]]; then
        _filedir -d;
        return 0;
    fi;
    local -r mark_dirs=$(_rl_enabled mark-directories && echo y);
    local -r mark_symdirs=$(_rl_enabled mark-symlinked-directories && echo y);
    for i in ${CDPATH//:/'
'};
    do
        k="${#COMPREPLY[@]}";
        for j in $( compgen -d $i/$cur );
        do
            if [[ ( -n $mark_symdirs && -h $j || -n $mark_dirs && ! -h $j ) && ! -d ${j#$i/} ]]; then
                j+="/";
            fi;
            COMPREPLY[k++]=${j#$i/};
        done;
    done;
    _filedir -d;
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        i=${COMPREPLY[0]};
        if [[ "$i" == "$cur" && $i != "*/" ]]; then
            COMPREPLY[0]="${i}/";
        fi;
    fi;
    return 0
}
_cd_devices () 
{ 
    COMPREPLY+=($( compgen -f -d -X "!*/?([amrs])cd*" -- "${cur:-/dev/}" ))
}
_command () 
{ 
    local offset i;
    offset=1;
    for ((i=1; i <= COMP_CWORD; i++ ))
    do
        if [[ "${COMP_WORDS[i]}" != -* ]]; then
            offset=$i;
            break;
        fi;
    done;
    _command_offset $offset
}
_command_offset () 
{ 
    local word_offset=$1 i j;
    for ((i=0; i < $word_offset; i++ ))
    do
        for ((j=0; j <= ${#COMP_LINE}; j++ ))
        do
            [[ "$COMP_LINE" == "${COMP_WORDS[i]}"* ]] && break;
            COMP_LINE=${COMP_LINE:1};
            ((COMP_POINT--));
        done;
        COMP_LINE=${COMP_LINE#"${COMP_WORDS[i]}"};
        ((COMP_POINT-=${#COMP_WORDS[i]}));
    done;
    for ((i=0; i <= COMP_CWORD - $word_offset; i++ ))
    do
        COMP_WORDS[i]=${COMP_WORDS[i+$word_offset]};
    done;
    for ((i; i <= COMP_CWORD; i++ ))
    do
        unset COMP_WORDS[i];
    done;
    ((COMP_CWORD -= $word_offset));
    COMPREPLY=();
    local cur;
    _get_comp_words_by_ref cur;
    if [[ $COMP_CWORD -eq 0 ]]; then
        local IFS='
';
        compopt -o filenames;
        COMPREPLY=($( compgen -d -c -- "$cur" ));
    else
        local cmd=${COMP_WORDS[0]} compcmd=${COMP_WORDS[0]};
        local cspec=$( complete -p $cmd 2>/dev/null );
        if [[ ! -n $cspec && $cmd == */* ]]; then
            cspec=$( complete -p ${cmd##*/} 2>/dev/null );
            [[ -n $cspec ]] && compcmd=${cmd##*/};
        fi;
        if [[ ! -n $cspec ]]; then
            compcmd=${cmd##*/};
            _completion_loader $compcmd;
            cspec=$( complete -p $compcmd 2>/dev/null );
        fi;
        if [[ -n $cspec ]]; then
            if [[ ${cspec#* -F } != $cspec ]]; then
                local func=${cspec#*-F };
                func=${func%% *};
                if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
                    $func $cmd "${COMP_WORDS[${#COMP_WORDS[@]}-1]}" "${COMP_WORDS[${#COMP_WORDS[@]}-2]}";
                else
                    $func $cmd "${COMP_WORDS[${#COMP_WORDS[@]}-1]}";
                fi;
                local opt;
                while [[ $cspec == *" -o "* ]]; do
                    cspec=${cspec#*-o };
                    opt=${cspec%% *};
                    compopt -o $opt;
                    cspec=${cspec#$opt};
                done;
            else
                cspec=${cspec#complete};
                cspec=${cspec%%$compcmd};
                COMPREPLY=($( eval compgen "$cspec" -- '$cur' ));
            fi;
        else
            if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
                _minimal;
            fi;
        fi;
    fi
}
_complete_as_root () 
{ 
    [[ $EUID -eq 0 || -n ${root_command:-} ]]
}
_complete_vim_addons () 
{ 
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    prev=${COMP_WORDS[COMP_CWORD-1]};
    commands="list status install remove disable amend files show";
    any_command=$(echo $commands | sed -e 's/\s\+/|/g');
    options="-h --help -r --registry-dir -s --source-dir -t --target-dir -v --verbose -y --system-dir -w --system-wide -q --query";
    any_option=$(echo $options | sed -e 's/\s\+/|/g');
    if [[ "$prev" == 'vim-addons' ]] || [[ "$prev" == 'vim-addon-manager' ]] || [[ "$prev" == 'vam' ]]; then
        COMPREPLY=($( compgen -W "$commands" -- $cur ));
        return 0;
    fi;
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($( compgen -W "$options" -- $cur));
        return 0;
    fi;
    if [[ "$prev" == @(-r|--registry-dir|-s|--source-dir|-t|--target-dir|-y|--system-dir) ]]; then
        COMPREPLY=($( compgen -o dirnames -- $cur ));
        return 0;
    fi;
    command='';
    target_dir='';
    system_wide='';
    system_dir='';
    for ((i=0; i < ${#COMP_WORDS[@]}-1; i++))
    do
        if [[ ${COMP_WORDS[i]} == @($any_command) ]]; then
            command=${COMP_WORDS[i]};
        fi;
        if [[ ${COMP_WORDS[i]} == @(-w|--system-wide) ]]; then
            system_wide="--system-wide";
        fi;
        if [[ $i -gt 0 ]]; then
            if [[ ${COMP_WORDS[i-1]} == @(-t|--target-dir) ]]; then
                target_dir="--target-dir ${COMP_WORDS[i]}";
            fi;
            if [[ ${COMP_WORDS[i-1]} == @(-y|--system-dir) ]]; then
                system_dir="--system-dir ${COMP_WORDS[i]}";
            fi;
        fi;
    done;
    query="vim-addons status --query $system_wide $system_dir $target_dir";
    if [[ -z "$command" ]]; then
        COMPREPLY=();
        return 0;
    fi;
    case "$command" in 
        list)
            COMPREPLY=()
        ;;
        install)
            COMPREPLY=($(  $query | grep -e "^$cur" | grep -v -e "installed$" | sed -e 's/^\(\S\+\).*/\1/' ))
        ;;
        remove | disable | amend)
            COMPREPLY=($(  $query | grep -e "^$cur" | grep -e "installed$" | sed -e 's/^\(\S\+\).*/\1/' ))
        ;;
        *)
            COMPREPLY=($(grep -h "^addon: $cur" /usr/share/vim/registry/*.yaml | sed -e 's/^addon:\s*//'))
        ;;
    esac
}
_completion_loader () 
{ 
    local compfile=./completions;
    [[ $BASH_SOURCE == */* ]] && compfile="${BASH_SOURCE%/*}/completions";
    compfile+="/${1##*/}";
    [[ -f "$compfile" ]] && . "$compfile" &> /dev/null && return 124;
    complete -F _minimal "$1" && return 124
}
_configured_interfaces () 
{ 
    if [[ -f /etc/debian_version ]]; then
        COMPREPLY=($( compgen -W "$( sed -ne 's|^iface \([^ ]\{1,\}\).*$|\1|p'            /etc/network/interfaces )" -- "$cur" ));
    else
        if [[ -f /etc/SuSE-release ]]; then
            COMPREPLY=($( compgen -W "$( printf '%s\n'             /etc/sysconfig/network/ifcfg-* |             sed -ne 's|.*ifcfg-\(.*\)|\1|p' )" -- "$cur" ));
        else
            if [[ -f /etc/pld-release ]]; then
                COMPREPLY=($( compgen -W "$( command ls -B             /etc/sysconfig/interfaces |             sed -ne 's|.*ifcfg-\(.*\)|\1|p' )" -- "$cur" ));
            else
                COMPREPLY=($( compgen -W "$( printf '%s\n'             /etc/sysconfig/network-scripts/ifcfg-* |             sed -ne 's|.*ifcfg-\(.*\)|\1|p' )" -- "$cur" ));
            fi;
        fi;
    fi
}
_count_args () 
{ 
    local i cword words;
    __reassemble_comp_words_by_ref "$1" words cword;
    args=1;
    for i in "${words[@]:1:cword-1}";
    do
        [[ "$i" != -* ]] && args=$(($args+1));
    done
}
_debconf_show () 
{ 
    local cur;
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    COMPREPLY=($( compgen -W '--listowners --listdbs --db=' -- $cur ) $( apt-cache pkgnames -- $cur ))
}
_desktop_file_validate () 
{ 
    COMPRELY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    _filedir '@(desktop)'
}
_dvd_devices () 
{ 
    COMPREPLY+=($( compgen -f -d -X "!*/?(r)dvd*" -- "${cur:-/dev/}" ))
}
_expand () 
{ 
    if [[ "$cur" == \~*/* ]]; then
        eval cur=$cur 2> /dev/null;
    else
        if [[ "$cur" == \~* ]]; then
            cur=${cur#\~};
            COMPREPLY=($( compgen -P '~' -u "$cur" ));
            [[ ${#COMPREPLY[@]} -eq 1 ]] && eval COMPREPLY[0]=${COMPREPLY[0]};
            return ${#COMPREPLY[@]};
        fi;
    fi
}
_filedir () 
{ 
    local i IFS='
' xspec;
    _tilde "$cur" || return 0;
    local -a toks;
    local quoted x tmp;
    _quote_readline_by_ref "$cur" quoted;
    x=$( compgen -d -- "$quoted" ) && while read -r tmp; do
        toks+=("$tmp");
    done <<< "$x";
    if [[ "$1" != -d ]]; then
        xspec=${1:+"!*.@($1|${1^^})"};
        x=$( compgen -f -X "$xspec" -- $quoted ) && while read -r tmp; do
            toks+=("$tmp");
        done <<< "$x";
    fi;
    [[ -n ${COMP_FILEDIR_FALLBACK:-} && -n "$1" && "$1" != -d && ${#toks[@]} -lt 1 ]] && x=$( compgen -f -- $quoted ) && while read -r tmp; do
        toks+=("$tmp");
    done <<< "$x";
    if [[ ${#toks[@]} -ne 0 ]]; then
        compopt -o filenames 2> /dev/null;
        COMPREPLY+=("${toks[@]}");
    fi
}
_filedir_xspec () 
{ 
    local cur prev words cword;
    _init_completion || return;
    _tilde "$cur" || return 0;
    local IFS='
' xspec=${_xspecs[${1##*/}]} tmp;
    local -a toks;
    toks=($(
        compgen -d -- "$(quote_readline "$cur")" | {
        while read -r tmp; do
            printf '%s\n' $tmp
        done
        }
        ));
    eval xspec="${xspec}";
    local matchop=!;
    if [[ $xspec == !* ]]; then
        xspec=${xspec#!};
        matchop=@;
    fi;
    xspec="$matchop($xspec|${xspec^^})";
    toks+=($(
        eval compgen -f -X "!$xspec" -- "\$(quote_readline "\$cur")" | {
        while read -r tmp; do
            [[ -n $tmp ]] && printf '%s\n' $tmp
        done
        }
        ));
    if [[ ${#toks[@]} -ne 0 ]]; then
        compopt -o filenames;
        COMPREPLY=("${toks[@]}");
    fi
}
_fstypes () 
{ 
    local fss;
    if [[ -e /proc/filesystems ]]; then
        fss="$( cut -d'	' -f2 /proc/filesystems )
             $( awk '! /\*/ { print $NF }' /etc/filesystems 2>/dev/null )";
    else
        fss="$( awk '/^[ \t]*[^#]/ { print $3 }' /etc/fstab 2>/dev/null )
             $( awk '/^[ \t]*[^#]/ { print $3 }' /etc/mnttab 2>/dev/null )
             $( awk '/^[ \t]*[^#]/ { print $4 }' /etc/vfstab 2>/dev/null )
             $( awk '{ print $1 }' /etc/dfs/fstypes 2>/dev/null )
             $( [[ -d /etc/fs ]] && command ls /etc/fs )";
    fi;
    [[ -n $fss ]] && COMPREPLY+=($( compgen -W "$fss" -- "$cur" ))
}
_gem191 () 
{ 
    local cur prev completions;
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    prev=${COMP_WORDS[COMP_CWORD-1]};
    COMMANDS='build cert check cleanup contents dependency\
      environment fetch generate_index help install list\
      lock mirror outdated pristine query rdoc search server\
      sources specification uninstall unpack update which';
    GEM_OPTIONS='\
      -h --help\
      -v --version';
    COMMON_OPTIONS='\
      -h --help\
      -V --verbose --no-verbose\
      -q --quiet\
      --config-file\
      --backtrace\
      --debug';
    CERT_OPTIONS='\
      -a -add\
      -l --list\
      -r --remove\
      -b --build\
      -C --certificate\
      -K --private-key\
      -s --sign';
    CHECK_OPTIONS='\
      --verify\
      -a --alien\
      -t --test\
      -v --version';
    CLEANUP_OPTIONS='\
      -d --dry-run';
    CONTENTS_OPTIONS='\
      -v --version\
      -s --spec-dir\
      -l --lib-only --no-lib-only';
    DEPENDENCY_OPTIONS='\
      -v --version\
      --platform\
      -R --reverse-dependencies --no-reverse-dependencies\
      -p --pipe';
    ENVIRONMENT_OPTIONS='';
    FETCH_OPTIONS='\
      -v --version\
      --platform\
      -B --bulk-threshold\
      -p --http-proxy --no-http-proxy\
      --source';
    GENERATE_INDEX_OPTIONS='\
      -d --directory';
    HELP_OPTIONS=$COMMANDS;
    INSTALL_OPTIONS='\
      --platform\
      -v --version\
      -i --install-dir\
      -d --rdoc --no-rdoc\
      --ri --no-ri\
      -E --env-shebang\
      -f --force --no-force\
      -t --test --no-test\
      -w --wrappers --no-wrappers\
      -P --trust-policy\
      --ignore-dependencies\
      -y --include-dependencies\
      --format-executable --no-format-executable\
      -l --local\
      -r --remote\
      -b --both\
      -B --bulk-threshold\
      --source\
      -p --http-proxy --no-http-proxy\
      -u --update-sources --no-update-sources';
    LIST_OPTIONS='\
      -d --details --no-details\
      --versions --no-versions\
      -l --local\
      -r --remote\
      -b --both\
      -B --bulk-threshold\
      --source\
      -p --http-proxy --no-http-proxy\
      -u --update-sources --no-update-sources';
    LOCK_OPTIONS='\
      -s --strict --no-strict';
    MIRROR_OPTIONS='';
    OUTDATED_OPTIONS='\
      --platform';
    PRISTINE_OPTIONS='\
      --all\
      -v --version';
    QUERY_OPTIONS='\
      -n --name-matches\
      -d --details --no-details\
      --versions --no-versions\
      -l --local\
      -r --remote\
      -b --both\
      -B --bulk-threshold\
      --source\
      -p --http-proxy --no-http-proxy\
      -u --update-sources --no-update-sources';
    RDOC_OPTIONS='\
      --all\
      --rdoc --no-rdoc\
      --ri --no-ri\
      -v --version';
    SEARCH_OPTIONS='\
      -d --details --no-details\
      --versions --no-versions\
      -l --local\
      -r --remote\
      -b --both\
      -B --bulk-threshold\
      --source\
      -p --http-proxy --no-http-proxy\
      -u --update-sources --no-update-sources';
    SERVER_OPTIONS='\
      -p --port\
      -d --dir\
      --daemon --no-daemon';
    SOURCES_OPTIONS='\
      -a --add\
      -l --list\
      -r --remove\
      -u --update\
      -c --clear-all';
    SPECIFICATION_OPTIONS='\
      -v --version\
      --platform\
      --all\
      -l --local\
      -r --remote\
      -b --both\
      -B --bulk-threshold\
      --source\
      -p --http-proxy --no-http-proxy\
      -u --update-sources --no-update-sources';
    UNINSTALL_OPTIONS='\
      -a --all --no-all\
      -i --ignore-dependencies --no-ignore-dependencies\
      -x --executables --no-executables\
      -v --version\
      --platform';
    UNPACK_OPTIONS='\
      --target\
      -v --version';
    UPDATE_OPTIONS='\
      --system\
      --platform\
      -i --install-dir\
      -d --rdoc --no-rdoc\
      --ri --no-ri\
      -E --env-shebang\
      -f --force --no-force\
      -t --test --no-test\
      -w --wrappers --no-wrappers\
      -P --trust-policy\
      --ignore-dependencies\
      -y --include-dependencies\
      --format-executable --no-format-executable\
      -l --local\
      -r --remote\
      -b --both\
      -B --bulk-threshold\
      --source\
      -p --http-proxy --no-http-proxy\
      -u --update-sources --no-update-sources';
    WHICH_OPTIONS='\
      -a --all --no-all\
      -g --gems-first --no-gems-first';
    case "${prev}" in 
        build)
            completions="$COMMON_OPTIONS $BUILD_OPTIONS"
        ;;
        cert)
            completions="$COMMON_OPTIONS $CERT_OPTIONS"
        ;;
        check)
            completions="$COMMON_OPTIONS $CHECK_OPTIONS"
        ;;
        cleanup)
            completions="$COMMON_OPTIONS $CLEANUP_OPTIONS"
        ;;
        contents)
            completions="$COMMON_OPTIONS $CONTENTS_OPTIONS"
        ;;
        dependency)
            completions="$COMMON_OPTIONS $DEPENDENCY_OPTIONS"
        ;;
        environment)
            completions="$COMMON_OPTIONS $ENVIRONMENT_OPTIONS"
        ;;
        fetch)
            completions="$COMMON_OPTIONS $FETCH_OPTIONS"
        ;;
        generate_index)
            completions="$COMMON_OPTIONS $GENERATE_INDEX_OPTIONS"
        ;;
        help)
            completions="$COMMON_OPTIONS $HELP_OPTIONS"
        ;;
        install)
            completions="$COMMON_OPTIONS $INSTALL_OPTIONS"
        ;;
        list)
            completions="$COMMON_OPTIONS $LIST_OPTIONS"
        ;;
        lock)
            completions="$COMMON_OPTIONS $LOCK_OPTIONS"
        ;;
        mirror)
            completions="$COMMON_OPTIONS $MIRROR_OPTIONS"
        ;;
        outdated)
            completions="$COMMON_OPTIONS $OUTDATED_OPTIONS"
        ;;
        pristine)
            completions="$COMMON_OPTIONS $PRISTINE_OPTIONS"
        ;;
        query)
            completions="$COMMON_OPTIONS $QUERY_OPTIONS"
        ;;
        rdoc)
            completions="$COMMON_OPTIONS $RDOC_OPTIONS"
        ;;
        search)
            completions="$COMMON_OPTIONS $SEARCH_OPTIONS"
        ;;
        server)
            completions="$COMMON_OPTIONS $SERVER_OPTIONS"
        ;;
        sources)
            completions="$COMMON_OPTIONS $SOURCES_OPTIONS"
        ;;
        specification)
            completions="$COMMON_OPTIONS $SPECIFICATION_OPTIONS"
        ;;
        uninstall)
            completions="$COMMON_OPTIONS $UNINSTALL_OPTIONS"
        ;;
        unpack)
            completions="$COMMON_OPTIONS $UNPACK_OPTIONS"
        ;;
        update)
            completions="$COMMON_OPTIONS $UPDATE_OPTIONS"
        ;;
        which)
            completions="$COMMON_OPTIONS $WHICH_OPTIONS"
        ;;
        *)
            completions="$COMMANDS $GEM_OPTIONS"
        ;;
    esac;
    COMPREPLY=($( compgen -W "$completions" -- $cur ));
    return 0
}
_get_comp_words_by_ref () 
{ 
    local exclude flag i OPTIND=1;
    local cur cword words=();
    local upargs=() upvars=() vcur vcword vprev vwords;
    while getopts "c:i:n:p:w:" flag "$@"; do
        case $flag in 
            c)
                vcur=$OPTARG
            ;;
            i)
                vcword=$OPTARG
            ;;
            n)
                exclude=$OPTARG
            ;;
            p)
                vprev=$OPTARG
            ;;
            w)
                vwords=$OPTARG
            ;;
        esac;
    done;
    while [[ $# -ge $OPTIND ]]; do
        case ${!OPTIND} in 
            cur)
                vcur=cur
            ;;
            prev)
                vprev=prev
            ;;
            cword)
                vcword=cword
            ;;
            words)
                vwords=words
            ;;
            *)
                echo "bash: $FUNCNAME(): \`${!OPTIND}': unknown argument" 1>&2;
                return 1
            ;;
        esac;
        let "OPTIND += 1";
    done;
    __get_cword_at_cursor_by_ref "$exclude" words cword cur;
    [[ -n $vcur ]] && { 
        upvars+=("$vcur");
        upargs+=(-v $vcur "$cur")
    };
    [[ -n $vcword ]] && { 
        upvars+=("$vcword");
        upargs+=(-v $vcword "$cword")
    };
    [[ -n $vprev && $cword -ge 1 ]] && { 
        upvars+=("$vprev");
        upargs+=(-v $vprev "${words[cword - 1]}")
    };
    [[ -n $vwords ]] && { 
        upvars+=("$vwords");
        upargs+=(-a${#words[@]} $vwords "${words[@]}")
    };
    (( ${#upvars[@]} )) && local "${upvars[@]}" && _upvars "${upargs[@]}"
}
_get_cword () 
{ 
    local LC_CTYPE=C;
    local cword words;
    __reassemble_comp_words_by_ref "$1" words cword;
    if [[ -n ${2//[^0-9]/} ]]; then
        printf "%s" "${words[cword-$2]}";
    else
        if [[ "${#words[cword]}" -eq 0 || "$COMP_POINT" == "${#COMP_LINE}" ]]; then
            printf "%s" "${words[cword]}";
        else
            local i;
            local cur="$COMP_LINE";
            local index="$COMP_POINT";
            for ((i = 0; i <= cword; ++i ))
            do
                while [[ "${#cur}" -ge ${#words[i]} && "${cur:0:${#words[i]}}" != "${words[i]}" ]]; do
                    cur="${cur:1}";
                    ((index--));
                done;
                if [[ "$i" -lt "$cword" ]]; then
                    local old_size="${#cur}";
                    cur="${cur#${words[i]}}";
                    local new_size="${#cur}";
                    index=$(( index - old_size + new_size ));
                fi;
            done;
            if [[ "${words[cword]:0:${#cur}}" != "$cur" ]]; then
                printf "%s" "${words[cword]}";
            else
                printf "%s" "${cur:0:$index}";
            fi;
        fi;
    fi
}
_get_first_arg () 
{ 
    local i;
    arg=;
    for ((i=1; i < COMP_CWORD; i++ ))
    do
        if [[ "${COMP_WORDS[i]}" != -* ]]; then
            arg=${COMP_WORDS[i]};
            break;
        fi;
    done
}
_get_pword () 
{ 
    if [[ $COMP_CWORD -ge 1 ]]; then
        _get_cword "${@:-}" 1;
    fi
}
_gids () 
{ 
    if type getent &> /dev/null; then
        COMPREPLY=($( compgen -W '$( getent group | cut -d: -f3 )'             -- "$cur" ));
    else
        if type perl &> /dev/null; then
            COMPREPLY=($( compgen -W '$( perl -e '"'"'while (($gid) = (getgrent)[2]) { print $gid . "\n" }'"'"' )' -- "$cur" ));
        else
            COMPREPLY=($( compgen -W '$( cut -d: -f3 /etc/group )' -- "$cur" ));
        fi;
    fi
}
_grub_editenv () 
{ 
    local cur prev;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    case "$prev" in 
        create | list | set | unset)
            COMPREPLY=("");
            return
        ;;
    esac;
    __grubcomp "$(__grub_get_options_from_help)
                create list set unset"
}
_grub_install () 
{ 
    local cur prev last split=false;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    last=$(__grub_get_last_option);
    _split_longopt && split=true;
    case "$prev" in 
        --boot-directory)
            _filedir -d;
            return
        ;;
        --disk-module)
            __grubcomp "biosdisk ata";
            return
        ;;
    esac;
    $split && return 0;
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        case "$last" in 
            --modules)
                __grub_list_modules;
                return
            ;;
        esac;
        _filedir;
    fi
}
_grub_mkconfig () 
{ 
    local cur prev;
    COMPREPLY=();
    cur=`_get_cword`;
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        _filedir;
    fi
}
_grub_mkfont () 
{ 
    local cur;
    COMPREPLY=();
    cur=`_get_cword`;
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        _filedir;
    fi
}
_grub_mkimage () 
{ 
    local cur prev split=false;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    _split_longopt && split=true;
    case "$prev" in 
        -d | --directory | -p | --prefix)
            _filedir -d;
            return
        ;;
        -O | --format)
            local prog=${COMP_WORDS[0]};
            __grubcomp "$(LC_ALL=C $prog --help |                         awk -F ":" '/available formats/ { print $2 }' |                         sed 's/, / /g')";
            return
        ;;
    esac;
    $split && return 0;
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        _filedir;
    fi
}
_grub_mkpasswd_pbkdf2 () 
{ 
    local cur;
    COMPREPLY=();
    cur=`_get_cword`;
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        _filedir;
    fi
}
_grub_mkrescue () 
{ 
    local cur prev last;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    last=$(__grub_get_last_option);
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        case "$last" in 
            --modules)
                __grub_list_modules;
                return
            ;;
        esac;
        _filedir;
    fi
}
_grub_probe () 
{ 
    local cur prev split=false;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    _split_longopt && split=true;
    case "$prev" in 
        -t | --target)
            local prog=${COMP_WORDS[0]};
            __grubcomp "$(LC_ALL=C $prog --help |                         awk -F "[()]" '/--target=/ { print $2 }' |                         sed 's/|/ /g')";
            return
        ;;
    esac;
    $split && return 0;
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        _filedir;
    fi
}
_grub_script_check () 
{ 
    local cur;
    COMPREPLY=();
    cur=`_get_cword`;
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        _filedir;
    fi
}
_grub_set_entry () 
{ 
    local cur prev split=false;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    _split_longopt && split=true;
    case "$prev" in 
        --boot-directory)
            _filedir -d;
            return
        ;;
    esac;
    $split && return 0;
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        __grub_list_menuentries;
    fi
}
_grub_setup () 
{ 
    local cur prev split=false;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    _split_longopt && split=true;
    case "$prev" in 
        -d | --directory)
            _filedir -d;
            return
        ;;
    esac;
    $split && return 0;
    if [[ "$cur" == -* ]]; then
        __grubcomp "$(__grub_get_options_from_help)";
    else
        _filedir;
    fi
}
_have () 
{ 
    PATH=$PATH:/usr/sbin:/sbin:/usr/local/sbin type $1 &> /dev/null
}
_init_completion () 
{ 
    local exclude= flag outx errx inx OPTIND=1;
    while getopts "n:e:o:i:s" flag "$@"; do
        case $flag in 
            n)
                exclude+=$OPTARG
            ;;
            e)
                errx=$OPTARG
            ;;
            o)
                outx=$OPTARG
            ;;
            i)
                inx=$OPTARG
            ;;
            s)
                split=false;
                exclude+==
            ;;
        esac;
    done;
    COMPREPLY=();
    local redir="@(?([0-9])<|?([0-9&])>?(>)|>&)";
    _get_comp_words_by_ref -n "$exclude<>&" cur prev words cword;
    _variables && return 1;
    if [[ $cur == $redir* || $prev == $redir ]]; then
        local xspec;
        case $cur in 
            2'>'*)
                xspec=$errx
            ;;
            *'>'*)
                xspec=$outx
            ;;
            *'<'*)
                xspec=$inx
            ;;
            *)
                case $prev in 
                    2'>'*)
                        xspec=$errx
                    ;;
                    *'>'*)
                        xspec=$outx
                    ;;
                    *'<'*)
                        xspec=$inx
                    ;;
                esac
            ;;
        esac;
        cur="${cur##$redir}";
        _filedir $xspec;
        return 1;
    fi;
    local i skip;
    for ((i=1; i < ${#words[@]}; 1))
    do
        if [[ ${words[i]} == $redir* ]]; then
            [[ ${words[i]} == $redir ]] && skip=2 || skip=1;
            words=("${words[@]:0:i}" "${words[@]:i+skip}");
            [[ $i -le $cword ]] && cword=$(( cword - skip ));
        else
            i=$(( ++i ));
        fi;
    done;
    [[ $cword -le 0 ]] && return 1;
    prev=${words[cword-1]};
    [[ -n ${split-} ]] && _split_longopt && split=true;
    return 0
}
_inkscape () 
{ 
    local cur;
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($( compgen -W '-? --help --usage -V --version \
			-z --without-gui -g --with-gui -f --file= -p --print= \
			-e --export-png= -d --export-dpi= -a --export-area= \
			-w --export-width= -h --export-height= -i --export-id= \
			-j --export-id-only  -t --export-use-hints -b --export-background= \
			-y --export-background-opacity= -l --export-plain-svg= -s --slideshow' -- $cur ));
    else
        _filedir '@(ai|ani|bmp|cur|dia|eps|gif|ggr|ico|jpe|jpeg|jpg|pbm|pcx|pdf|pgm|png|ppm|pnm|ps|ras|sk|svg|svgz|targa|tga|tif|tiff|txt|wbmp|wmf|xbm|xpm)';
    fi
}
_installed_modules () 
{ 
    COMPREPLY=($( compgen -W "$( PATH="$PATH:/sbin" lsmod |         awk '{if (NR != 1) print $1}' )" -- "$1" ))
}
_ip_addresses () 
{ 
    local PATH=$PATH:/sbin;
    COMPREPLY+=($( compgen -W         "$( { LC_ALL=C ifconfig -a || ip addr show; } 2>/dev/null |
            sed -ne 's/.*addr:\([^[:space:]]*\).*/\1/p'                 -ne 's|.*inet[[:space:]]\{1,\}\([^[:space:]/]*\).*|\1|p' )"         -- "$cur" ))
}
_kernel_versions () 
{ 
    COMPREPLY=($( compgen -W '$( command ls /lib/modules )' -- "$cur" ))
}
_known_hosts () 
{ 
    local cur prev words cword;
    _init_completion -n : || return;
    local options;
    [[ "$1" == -a || "$2" == -a ]] && options=-a;
    [[ "$1" == -c || "$2" == -c ]] && options+=" -c";
    _known_hosts_real $options -- "$cur"
}
_known_hosts_real () 
{ 
    local configfile flag prefix;
    local cur curd awkcur user suffix aliases i host;
    local -a kh khd config;
    local OPTIND=1;
    while getopts "acF:p:" flag "$@"; do
        case $flag in 
            a)
                aliases='yes'
            ;;
            c)
                suffix=':'
            ;;
            F)
                configfile=$OPTARG
            ;;
            p)
                prefix=$OPTARG
            ;;
        esac;
    done;
    [[ $# -lt $OPTIND ]] && echo "error: $FUNCNAME: missing mandatory argument CWORD";
    cur=${!OPTIND};
    let "OPTIND += 1";
    [[ $# -ge $OPTIND ]] && echo "error: $FUNCNAME("$@"): unprocessed arguments:" $(while [[ $# -ge $OPTIND ]]; do printf '%s\n' ${!OPTIND}; shift; done);
    [[ $cur == *@* ]] && user=${cur%@*}@ && cur=${cur#*@};
    kh=();
    if [[ -n $configfile ]]; then
        [[ -r $configfile ]] && config+=("$configfile");
    else
        for i in /etc/ssh/ssh_config ~/.ssh/config ~/.ssh2/config;
        do
            [[ -r $i ]] && config+=("$i");
        done;
    fi;
    if [[ ${#config[@]} -gt 0 ]]; then
        local OIFS=$IFS IFS='
' j;
        local -a tmpkh;
        tmpkh=($( awk 'sub("^[ \t]*([Gg][Ll][Oo][Bb][Aa][Ll]|[Uu][Ss][Ee][Rr])[Kk][Nn][Oo][Ww][Nn][Hh][Oo][Ss][Tt][Ss][Ff][Ii][Ll][Ee][ \t]+", "") { print $0 }' "${config[@]}" | sort -u ));
        IFS=$OIFS;
        for i in "${tmpkh[@]}";
        do
            while [[ $i =~ ^([^\"]*)\"([^\"]*)\"(.*)$ ]]; do
                i=${BASH_REMATCH[1]}${BASH_REMATCH[3]};
                j=${BASH_REMATCH[2]};
                __expand_tilde_by_ref j;
                [[ -r $j ]] && kh+=("$j");
            done;
            for j in $i;
            do
                __expand_tilde_by_ref j;
                [[ -r $j ]] && kh+=("$j");
            done;
        done;
    fi;
    if [[ -z $configfile ]]; then
        for i in /etc/ssh/ssh_known_hosts /etc/ssh/ssh_known_hosts2 /etc/known_hosts /etc/known_hosts2 ~/.ssh/known_hosts ~/.ssh/known_hosts2;
        do
            [[ -r $i ]] && kh+=("$i");
        done;
        for i in /etc/ssh2/knownhosts ~/.ssh2/hostkeys;
        do
            [[ -d $i ]] && khd+=("$i"/*pub);
        done;
    fi;
    if [[ ${#kh[@]} -gt 0 || ${#khd[@]} -gt 0 ]]; then
        awkcur=${cur//\//\\\/};
        awkcur=${awkcur//\./\\\.};
        curd=$awkcur;
        if [[ "$awkcur" == [0-9]*[.:]* ]]; then
            awkcur="^$awkcur[.:]*";
        else
            if [[ "$awkcur" == [0-9]* ]]; then
                awkcur="^$awkcur.*[.:]";
            else
                if [[ -z $awkcur ]]; then
                    awkcur="[a-z.:]";
                else
                    awkcur="^$awkcur";
                fi;
            fi;
        fi;
        if [[ ${#kh[@]} -gt 0 ]]; then
            COMPREPLY+=($( awk 'BEGIN {FS=","}
            /^\s*[^|\#]/ {
            sub("^@[^ ]+ +", ""); \
            sub(" .*$", ""); \
            for (i=1; i<=NF; ++i) { \
            sub("^\\[", "", $i); sub("\\](:[0-9]+)?$", "", $i); \
            if ($i !~ /[*?]/ && $i ~ /'"$awkcur"'/) {print $i} \
            }}' "${kh[@]}" 2>/dev/null ));
        fi;
        if [[ ${#khd[@]} -gt 0 ]]; then
            for i in "${khd[@]}";
            do
                if [[ "$i" == *key_22_$curd*.pub && -r "$i" ]]; then
                    host=${i/#*key_22_/};
                    host=${host/%.pub/};
                    COMPREPLY+=($host);
                fi;
            done;
        fi;
        for ((i=0; i < ${#COMPREPLY[@]}; i++ ))
        do
            COMPREPLY[i]=$prefix$user${COMPREPLY[i]}$suffix;
        done;
    fi;
    if [[ ${#config[@]} -gt 0 && -n "$aliases" ]]; then
        local hosts=$( sed -ne 's/^[ \t]*[Hh][Oo][Ss][Tt]\([Nn][Aa][Mm][Ee]\)\{0,1\}['"$'\t '"']\{1,\}\([^#*?]*\)\(#.*\)\{0,1\}$/\2/p' "${config[@]}" );
        COMPREPLY+=($( compgen -P "$prefix$user"             -S "$suffix" -W "$hosts" -- "$cur" ));
    fi;
    COMPREPLY+=($( compgen -W         "$( ruptime 2>/dev/null | awk '!/^ruptime:/ { print $1 }' )"         -- "$cur" ));
    if [[ -n ${COMP_KNOWN_HOSTS_WITH_HOSTFILE-1} ]]; then
        COMPREPLY+=($( compgen -A hostname -P "$prefix$user" -S "$suffix" -- "$cur" ));
    fi;
    __ltrim_colon_completions "$prefix$user$cur";
    return 0
}
_loexp_ () 
{ 
    local c=${COMP_WORDS[COMP_CWORD]};
    local a="${COMP_LINE}";
    local e s g=0 cd dc t="";
    local IFS;
    shopt -q extglob && g=1;
    test $g -eq 0 && shopt -s extglob;
    cd='*-?(c)d*';
    dc='*-d?(c)*';
    case "${1##*/}" in 
        lomath)
            e='!*.+(sxm|SXM|smf|SMF|mml|MML|odf|ODF)'
        ;;
        lofromtemplate)
            e='!*.+(stw|STW|dot|DOT|vor|VOR|stc|STC|xlt|XLT|sti|STI|pot|POT|std|STD|stw|STW|dotm|DOTM|dotx|DOTX|potm|POTM|potx|POTX|xltm|XLTM|xltx|XLTX)'
        ;;
        unopkg)
            e='!*.+(oxt|OXT)'
        ;;
        loimpress)
            e='!*.+(sxi|SXI|sti|STI|ppt|PPT|pps|PPS|pot|POT|sxd|SXD|sda|SDA|sdd|SDD|sdp|SDP|vor|VOR|cgm|CGM|odp|ODP|otp|OTP|fodp|FODP|ppsm|PPSM|ppsx|PPSX|pptm|PPTM|pptx|PPTX|potm|POTM|potx|POTX)'
        ;;
        loweb)
            e='!*.+(htm|HTM|html|HTML|stw|STW|txt|TXT|vor|VOR|oth|OTH)'
        ;;
        lowriter)
            e='!*.+(doc|DOC|dot|DOT|rtf|RTF|sxw|SXW|stw|STW|sdw|SDW|vor|VOR|txt|TXT|htm?|HTM?|xml|XML|wp|WP|wpd|WPD|wps|WPS|odt|ODT|ott|OTT|fodt|FODT|docm|DOCM|docx|DOCX|dotm|DOTM|dotx|DOTX|sxg|SXG|odm|ODM|sgl|SGL)'
        ;;
        localc)
            e='!*.+(sxc|SXC|stc|STC|dif|DIF|dbf|DBF|xls|XLS|xlw|XLW|xlt|XLT|rtf|RTF|sdc|SDC|vor|VOR|slk|SLK|txt|TXT|htm|HTM|html|HTML|wk1|WK1|wks|WKS|123|123|xml|XML|ods|ODS|ots|OTS|fods|FODS|csv|CSV|xlsb|XLSB|xlsm|XLSM|xlsx|XLSX|xltm|XLTM|xltx|XLTX)'
        ;;
        libreoffice)
            e='!*.+(sxd|SXD|std|STD|dxf|DXF|emf|EMF|eps|EPS|met|MET|pct|PCT|sgf|SGF|sgv|SGV|sda|SDA|sdd|SDD|vor|VOR|svm|SVM|wmf|WMF|bmp|BMP|gif|GIF|jpg|JPG|jpeg|JPEG|jfif|JFIF|fif|FIF|jpe|JPE|pcd|PCD|pcx|PCX|pgm|PGM|png|PNG|ppm|PPM|psd|PSD|ras|RAS|tga|TGA|tif|TIF|tiff|TIFF|xbm|XBM|xpm|XPM|odg|ODG|otg|OTG|fodg|FODG|odc|ODC|odi|ODI|sds|SDS|wpg|WPG|svg|SVG|doc|DOC|dot|DOT|rtf|RTF|sxw|SXW|stw|STW|sdw|SDW|vor|VOR|txt|TXT|htm?|HTM?|xml|XML|wp|WP|wpd|WPD|wps|WPS|odt|ODT|ott|OTT|fodt|FODT|docm|DOCM|docx|DOCX|dotm|DOTM|dotx|DOTX|sxm|SXM|smf|SMF|mml|MML|odf|ODF|sxi|SXI|sti|STI|ppt|PPT|pps|PPS|pot|POT|sxd|SXD|sda|SDA|sdd|SDD|sdp|SDP|vor|VOR|cgm|CGM|odp|ODP|otp|OTP|fodp|FODP|ppsm|PPSM|ppsx|PPSX|pptm|PPTM|pptx|PPTX|potm|POTM|potx|POTX|odb|ODB|sxc|SXC|stc|STC|dif|DIF|dbf|DBF|xls|XLS|xlw|XLW|xlt|XLT|rtf|RTF|sdc|SDC|vor|VOR|slk|SLK|txt|TXT|htm|HTM|html|HTML|wk1|WK1|wks|WKS|123|123|xml|XML|ods|ODS|ots|OTS|fods|FODS|csv|CSV|xlsb|XLSB|xlsm|XLSM|xlsx|XLSX|xltm|XLTM|xltx|XLTX|sxg|SXG|odm|ODM|sgl|SGL|stw|STW|dot|DOT|vor|VOR|stc|STC|xlt|XLT|sti|STI|pot|POT|std|STD|stw|STW|dotm|DOTM|dotx|DOTX|potm|POTM|potx|POTX|xltm|XLTM|xltx|XLTX|htm|HTM|html|HTML|stw|STW|txt|TXT|vor|VOR|oth|OTH)'
        ;;
        lobase)
            e='!*.+(odb|ODB)'
        ;;
        lodraw)
            e='!*.+(sxd|SXD|std|STD|dxf|DXF|emf|EMF|eps|EPS|met|MET|pct|PCT|sgf|SGF|sgv|SGV|sda|SDA|sdd|SDD|vor|VOR|svm|SVM|wmf|WMF|bmp|BMP|gif|GIF|jpg|JPG|jpeg|JPEG|jfif|JFIF|fif|FIF|jpe|JPE|pcd|PCD|pcx|PCX|pgm|PGM|png|PNG|ppm|PPM|psd|PSD|ras|RAS|tga|TGA|tif|TIF|tiff|TIFF|xbm|XBM|xpm|XPM|odg|ODG|otg|OTG|fodg|FODG|odc|ODC|odi|ODI|sds|SDS|wpg|WPG|svg|SVG)'
        ;;
        loffice)
            e='!*.+(sxd|SXD|std|STD|dxf|DXF|emf|EMF|eps|EPS|met|MET|pct|PCT|sgf|SGF|sgv|SGV|sda|SDA|sdd|SDD|vor|VOR|svm|SVM|wmf|WMF|bmp|BMP|gif|GIF|jpg|JPG|jpeg|JPEG|jfif|JFIF|fif|FIF|jpe|JPE|pcd|PCD|pcx|PCX|pgm|PGM|png|PNG|ppm|PPM|psd|PSD|ras|RAS|tga|TGA|tif|TIF|tiff|TIFF|xbm|XBM|xpm|XPM|odg|ODG|otg|OTG|fodg|FODG|odc|ODC|odi|ODI|sds|SDS|wpg|WPG|svg|SVG|doc|DOC|dot|DOT|rtf|RTF|sxw|SXW|stw|STW|sdw|SDW|vor|VOR|txt|TXT|htm?|HTM?|xml|XML|wp|WP|wpd|WPD|wps|WPS|odt|ODT|ott|OTT|fodt|FODT|docm|DOCM|docx|DOCX|dotm|DOTM|dotx|DOTX|sxm|SXM|smf|SMF|mml|MML|odf|ODF|sxi|SXI|sti|STI|ppt|PPT|pps|PPS|pot|POT|sxd|SXD|sda|SDA|sdd|SDD|sdp|SDP|vor|VOR|cgm|CGM|odp|ODP|otp|OTP|fodp|FODP|ppsm|PPSM|ppsx|PPSX|pptm|PPTM|pptx|PPTX|potm|POTM|potx|POTX|odb|ODB|sxc|SXC|stc|STC|dif|DIF|dbf|DBF|xls|XLS|xlw|XLW|xlt|XLT|rtf|RTF|sdc|SDC|vor|VOR|slk|SLK|txt|TXT|htm|HTM|html|HTML|wk1|WK1|wks|WKS|123|123|xml|XML|ods|ODS|ots|OTS|fods|FODS|csv|CSV|xlsb|XLSB|xlsm|XLSM|xlsx|XLSX|xltm|XLTM|xltx|XLTX|sxg|SXG|odm|ODM|sgl|SGL|stw|STW|dot|DOT|vor|VOR|stc|STC|xlt|XLT|sti|STI|pot|POT|std|STD|stw|STW|dotm|DOTM|dotx|DOTX|potm|POTM|potx|POTX|xltm|XLTM|xltx|XLTX|htm|HTM|html|HTML|stw|STW|txt|TXT|vor|VOR|oth|OTH)'
        ;;
        *)
            e='!*'
        ;;
    esac;
    case "$(complete -p ${1##*/} 2> /dev/null)" in 
        *-d*)

        ;;
        *)
            s="-S/"
        ;;
    esac;
    IFS='
';
    case "$c" in 
        \$\(*\))
            eval COMPREPLY=\(${c}\)
        ;;
        \$\(*)
            COMPREPLY=($(compgen -c -P '$(' -S ')'  -- ${c#??}))
        ;;
        \`*\`)
            eval COMPREPLY=\(${c}\)
        ;;
        \`*)
            COMPREPLY=($(compgen -c -P '\`' -S '\`' -- ${c#?}))
        ;;
        \$\{*\})
            eval COMPREPLY=\(${c}\)
        ;;
        \$\{*)
            COMPREPLY=($(compgen -v -P '${' -S '}'  -- ${c#??}))
        ;;
        \$*)
            COMPREPLY=($(compgen -v -P '$'          -- ${c#?}))
        ;;
        \~*/*)
            COMPREPLY=($(compgen -f -X "$e"         -- ${c}))
        ;;
        \~*)
            COMPREPLY=($(compgen -u ${s}	 	-- ${c}))
        ;;
        *@*)
            COMPREPLY=($(compgen -A hostname -P '@' -S ':' -- ${c#*@}))
        ;;
        *[*?[]*)
            COMPREPLY=($(compgen -G "${c}"))
        ;;
        *[?*+\!@]\(*\)*)
            if test $g -eq 0; then
                COMPREPLY=($(compgen -f -X "$e" -- $c));
                test $g -eq 0 && shopt -u extglob;
                return;
            fi;
            COMPREPLY=($(compgen -G "${c}"))
        ;;
        *)
            if test "$c" = ".."; then
                COMPREPLY=($(compgen -d -X "$e" -S / ${_nosp} -- $c));
            else
                for s in $(compgen -f -X "$e" -- $c);
                do
                    if test -d $s; then
                        COMPREPLY=(${COMPREPLY[@]} $(compgen -f -X "$e" -S / -- $s));
                    else
                        if test -z "$t"; then
                            COMPREPLY=(${COMPREPLY[@]} $s);
                        else
                            case "$(file -b $s 2> /dev/null)" in 
                                $t)
                                    COMPREPLY=(${COMPREPLY[@]} $s)
                                ;;
                            esac;
                        fi;
                    fi;
                done;
            fi
        ;;
    esac;
    test $g -eq 0 && shopt -u extglob
}
_longopt () 
{ 
    local cur prev words cword split;
    _init_completion -s || return;
    case "${prev,,}" in 
        --help | --usage | --version)
            return 0
        ;;
        --*dir*)
            _filedir -d;
            return 0
        ;;
        --*file* | --*path*)
            _filedir;
            return 0
        ;;
        --+([-a-z0-9_]))
            local argtype=$( $1 --help 2>&1 | sed -ne                 "s|.*$prev\[\{0,1\}=[<[]\{0,1\}\([-A-Za-z0-9_]\{1,\}\).*|\1|p" );
            case ${argtype,,} in 
                *dir*)
                    _filedir -d;
                    return 0
                ;;
                *file* | *path*)
                    _filedir;
                    return 0
                ;;
            esac
        ;;
    esac;
    $split && return 0;
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($( compgen -W "$( $1 --help 2>&1 |             sed -ne 's/.*\(--[-A-Za-z0-9]\{1,\}=\{0,1\}\).*/\1/p' | sort -u )"             -- "$cur" ));
        [[ $COMPREPLY == *= ]] && compopt -o nospace;
    else
        if [[ "$1" == @(mk|rm)dir ]]; then
            _filedir -d;
        else
            _filedir;
        fi;
    fi
}
_mac_addresses () 
{ 
    local re='\([A-Fa-f0-9]\{2\}:\)\{5\}[A-Fa-f0-9]\{2\}';
    local PATH="$PATH:/sbin:/usr/sbin";
    COMPREPLY+=($(         { LC_ALL=C ifconfig -a || ip link show; } 2>/dev/null | sed -ne         "s/.*[[:space:]]HWaddr[[:space:]]\{1,\}\($re\)[[:space:]].*/\1/p" -ne         "s/.*[[:space:]]HWaddr[[:space:]]\{1,\}\($re\)[[:space:]]*$/\1/p" -ne         "s|.*[[:space:]]\(link/\)\{0,1\}ether[[:space:]]\{1,\}\($re\)[[:space:]].*|\2|p" -ne         "s|.*[[:space:]]\(link/\)\{0,1\}ether[[:space:]]\{1,\}\($re\)[[:space:]]*$|\2|p"
        ));
    COMPREPLY+=($( { arp -an || ip neigh show; } 2>/dev/null | sed -ne         "s/.*[[:space:]]\($re\)[[:space:]].*/\1/p" -ne         "s/.*[[:space:]]\($re\)[[:space:]]*$/\1/p" ));
    COMPREPLY+=($( sed -ne         "s/^[[:space:]]*\($re\)[[:space:]].*/\1/p" /etc/ethers 2>/dev/null ));
    COMPREPLY=($( compgen -W '${COMPREPLY[@]}' -- "$cur" ));
    __ltrim_colon_completions "$cur"
}
_minimal () 
{ 
    local cur prev words cword split;
    _init_completion -s || return;
    $split && return;
    _filedir
}
_modules () 
{ 
    local modpath;
    modpath=/lib/modules/$1;
    COMPREPLY=($( compgen -W "$( command ls -RL $modpath 2>/dev/null |         sed -ne 's/^\(.*\)\.k\{0,1\}o\(\.[gx]z\)\{0,1\}$/\1/p' )" -- "$cur" ))
}
_ncpus () 
{ 
    local var=NPROCESSORS_ONLN;
    [[ $OSTYPE == *linux* ]] && var=_$var;
    local n=$( getconf $var 2>/dev/null );
    printf %s ${n:-1}
}
_pacat () 
{ 
    local cur prev comps;
    local flags='-h --help --version -r --record -p --playback -v --verbose -s
                --server= -d --device= -n --client-name= --stream-name= --volume=
                --rate= --format= --channels= --channel-map= --fix-format --fix-rate
                --fix-channels --no-remix --no-remap --latency= --process-time=
                --latency-msec= --process-time-msec= --property= --raw --passthrough
                --file-format= --list-file-formats';
    _init_completion -n = || return;
    case $cur in 
        --server=*)
            cur=${cur#*=};
            _known_hosts_real "$cur"
        ;;
        --device=*)
            cur=${cur#*=};
            comps=$(__sinks);
            comps+=$(__sources);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        --rate=*)
            cur=${cur#*=};
            COMPREPLY=($(compgen -W '32000 44100 48000 9600 192000' -- "$cur"))
        ;;
        --file-format=*)
            cur=${cur#*=};
            comps=$(_pacat_file_formats);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        --*=*)

        ;;
        -*)
            COMPREPLY=($(compgen -W '${flags[*]}' -- "$cur"));
            [[ $COMPREPLY == *= ]] && compopt -o nospace
        ;;
        *)
            _filedir
        ;;
    esac;
    case $prev in 
        -s)
            _known_hosts_real "$cur"
        ;;
        -d)
            comps=$(__sinks);
            comps+=$(__sources);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
    esac
}
_pacat_file_formats () 
{ 
    while IFS='	' read name _; do
        printf "%s\n" "$name";
    done < <(pacat --list-file-formats 2> /dev/null)
}
_pacmd () 
{ 
    local cur prev words cword preprev command;
    local comps;
    local flags='-h --help --version';
    local commands=(exit help list-modules list-sinks list-sources list-clients list-samples list-sink-inputs list-source-outputs stat info load-module unload-module describe-module set-sink-volume set-source-volume set-sink-input-volume set-source-output-volume set-sink-mute set-source-mut set-sink-input-mute set-source-output-mute update-sink-proplist update-source-proplist update-sink-input-proplist update-source-output-proplist set-default-sink set-default-source kill-client kill-sink-input kill-source-output play-sample remove-sample load-sample load-sample-lazy load-sample-dir-lazy play-file dump move-sink-input move-source-output suspend-sink suspend-source suspend set-card-profile set-sink-port set-source-port set-port-latency-offset set-log-target set-log-level set-log-meta set-log-time set-log-backtrace);
    _init_completion -n = || return;
    preprev=${words[$cword-2]};
    for word in "${COMP_WORDS[@]}";
    do
        if in_array "$word" "${commands[@]}"; then
            command=$word;
            break;
        fi;
    done;
    case $preprev in 
        play-sample | play-file)
            comps=$(__sinks);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        load-sample*)
            _filedir
        ;;
        move-sink-input)
            comps=$(__sinks);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        move-source-output)
            comps=$(__sources);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-card-profile)
            comps=$(__profiles);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-*port*)
            comps=$(__ports);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-*-mute)
            COMPREPLY=($(compgen -W 'true false' -- "$cur"))
        ;;
        set-sink-formats)

        ;;
    esac;
    case $prev in 
        list-*)

        ;;
        describe-module | load-module)
            comps=$(__all_modules);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        unload-module)
            comps=$(__loaded_modules);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        load-sample-dir-lazy)
            _filedir -d
        ;;
        play-file)
            _filedir
        ;;
        *sink-input*)
            comps=$(__sink_inputs);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        *source-output*)
            comps=$(__source_outputs);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        *sink*)
            comps=$(__sinks);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        *source*)
            comps=$(__sources);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-card*)
            comps=$(__cards);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-port-*)
            comps=$(__cards);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-log-target)
            COMPREPLY=($(compgen -W 'auto syslog stderr file: newfile:' -- "$cur"))
        ;;
        set-log-level)
            COMPREPLY=($(compgen -W '{0..4}' -- "$cur"))
        ;;
        set-log-meta | set-log-time | suspend)
            COMPREPLY=($(compgen -W 'true false' -- "$cur"))
        ;;
    esac;
    case $cur in 
        -*)
            COMPREPLY=($(compgen -W '${flags[*]}' -- "$cur"))
        ;;
        suspend)
            COMPREPLY=($(compgen -W 'suspend suspend-sink suspend-source' -- "$cur"))
        ;;
        load-sample)
            COMPREPLY=($(compgen -W 'load-sample load-sample-lazy load-sample-dir-lazy' -- "$cur"))
        ;;
        *)
            [[ -z $command ]] && COMPREPLY=($(compgen -W '${commands[*]}' -- "$cur"))
        ;;
    esac
}
_pactl () 
{ 
    local cur prev words cword preprev command;
    local comps;
    local flags='-h --help --version -s --server= --client-name=';
    local list_types='short sinks sources sink-inputs source outputs cards
                    modules samples clients';
    local commands=(stat info list exit upload-sample play-sample remove-sample load-module unload-module move-sink-input move-source-output suspend-sink suspend-source set-card-profile set-sink-port set-source-port set-sink-volume set-source-volume set-sink-input-volume set-source-output-volume set-sink-mute set-source-mute set-sink-input-mute set-source-output-mute set-sink-formats set-port-latency-offset subscribe help);
    _init_completion -n = || return;
    preprev=${words[$cword-2]};
    for word in "${COMP_WORDS[@]}";
    do
        if in_array "$word" "${commands[@]}"; then
            command=$word;
            break;
        fi;
    done;
    case $preprev in 
        list)
            COMPREPLY=($(compgen -W 'short' -- "$cur"))
        ;;
        play-sample)
            comps=$(__sinks);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        move-sink-input)
            comps=$(__sinks);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        move-source-output)
            comps=$(__sources);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-card-profile)
            comps=$(__profiles);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-*-port)
            comps=$(__ports);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-*-mute)
            COMPREPLY=($(compgen -W 'true false toggle' -- "$cur"))
        ;;
        set-sink-formats)

        ;;
        set-port-*)
            comps=$(__ports);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        --server)
            compopt +o nospace;
            _known_hosts_real "$cur"
        ;;
    esac;
    [[ -n $COMPREPLY ]] && return 0;
    case $prev in 
        list)
            COMPREPLY=($(compgen -W '${list_types[*]}' -- "$cur"))
        ;;
        stat)
            COMPREPLY=($(compgen -W 'short' -- "$cur"))
        ;;
        upload-sample)
            _filedir
        ;;
        play-sample)

        ;;
        remove-sample)

        ;;
        load-module)
            comps=$(__all_modules);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        unload-module)
            comps=$(__loaded_modules);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-card*)
            comps=$(__cards);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        *sink-input*)
            comps=$(__sink_inputs);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        *source-output*)
            comps=$(__source_outputs);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-sink-formats)
            comps=$(__sinks_idx);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        *sink*)
            comps=$(__sinks);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        *source*)
            comps=$(__sources);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        set-port*)
            comps=$(__cards);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        -s)
            _known_hosts_real "$cur"
        ;;
    esac;
    [[ -n $COMPREPLY ]] && return 0;
    case $cur in 
        --server=*)
            cur=${cur#*=};
            _known_hosts_real "$cur"
        ;;
        -*)
            COMPREPLY=($(compgen -W '${flags[*]}' -- "$cur"));
            [[ $COMPREPLY == *= ]] && compopt -o nospace
        ;;
        *)
            [[ -z $command ]] && COMPREPLY=($(compgen -W '${commands[*]}' -- "$cur"))
        ;;
    esac
}
_padsp () 
{ 
    local cur prev;
    local flags='-h -s -n -m -M -S -D -d';
    _get_comp_words_by_ref cur prev;
    case $cur in 
        -*)
            COMPREPLY=($(compgen -W '${flags[*]}' -- "$cur"))
        ;;
    esac;
    case $prev in 
        -s)
            _known_hosts_real "$cur"
        ;;
    esac
}
_parse_help () 
{ 
    eval local cmd=$( quote "$1" );
    local line;
    { 
        case $cmd in 
            -)
                cat
            ;;
            *)
                LC_ALL=C "$( dequote "$cmd" )" ${2:---help} 2>&1
            ;;
        esac
    } | while read -r line; do
        [[ $line == *([ '	'])-* ]] || continue;
        while [[ $line =~ ((^|[^-])-[A-Za-z0-9?][[:space:]]+)\[?[A-Z0-9]+\]? ]]; do
            line=${line/"${BASH_REMATCH[0]}"/"${BASH_REMATCH[1]}"};
        done;
        __parse_options "${line// or /, }";
    done
}
_parse_usage () 
{ 
    eval local cmd=$( quote "$1" );
    local line match option i char;
    { 
        case $cmd in 
            -)
                cat
            ;;
            *)
                LC_ALL=C "$( dequote "$cmd" )" ${2:---usage} 2>&1
            ;;
        esac
    } | while read -r line; do
        while [[ $line =~ \[[[:space:]]*(-[^]]+)[[:space:]]*\] ]]; do
            match=${BASH_REMATCH[0]};
            option=${BASH_REMATCH[1]};
            case $option in 
                -?(\[)+([a-zA-Z0-9?]))
                    for ((i=1; i < ${#option}; i++ ))
                    do
                        char=${option:i:1};
                        [[ $char != '[' ]] && printf '%s\n' -$char;
                    done
                ;;
                *)
                    __parse_options "$option"
                ;;
            esac;
            line=${line#*"$match"};
        done;
    done
}
_pasuspender () 
{ 
    local cur prev;
    local flags='-h --help --version -s --server=';
    _init_completion -n = || return;
    case $cur in 
        --server=*)
            cur=${cur#*=};
            _known_hosts_real "$cur"
        ;;
        -*)
            COMPREPLY=($(compgen -W '${flags[*]}' -- "$cur"));
            [[ $COMPREPLY == *= ]] && compopt -o nospace
        ;;
    esac;
    case $prev in 
        -s)
            _known_hosts_real "$cur"
        ;;
    esac
}
_pci_ids () 
{ 
    COMPREPLY+=($( compgen -W         "$( PATH="$PATH:/sbin" lspci -n | awk '{print $3}')" -- "$cur" ))
}
_pgids () 
{ 
    COMPREPLY=($( compgen -W '$( command ps axo pgid= )' -- "$cur" ))
}
_pids () 
{ 
    COMPREPLY=($( compgen -W '$( command ps axo pid= )' -- "$cur" ))
}
_pnames () 
{ 
    COMPREPLY=($( compgen -X '<defunct>' -W '$( command ps axo command= | \
        sed -e "s/ .*//" -e "s:.*/::" -e "s/:$//" -e "s/^[[(-]//" \
            -e "s/[])]$//" | sort -u )' -- "$cur" ))
}
_poff () 
{ 
    local prev cur conns;
    [ -r /etc/ppp/peers/ ] || return 0;
    COMPREPLY=();
    prev=${COMP_WORDS[COMP_CWORD-1]};
    cur=${COMP_WORDS[COMP_CWORD]};
    conns=$(\ls --color=none /etc/ppp/peers | egrep -v '(\.bak|~)$');
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W '-r -d -c -a -h -v' -- $cur));
        return 0;
    fi;
    if [ $COMP_CWORD -eq 1 ] && [[ "$cur" != -* ]] || [[ "$prev" == -* ]]; then
        COMPREPLY=($(compgen -o filenames -W "$conns" $cur));
    fi;
    return 0
}
_pon () 
{ 
    local cur conns;
    [ -r /etc/ppp/peers/ ] || return 0;
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    conns=$(\ls --color=none /etc/ppp/peers | egrep -v '(\.bak|~)$');
    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=($(compgen -o filenames -W "$conns" $cur));
    fi;
    return 0
}
_pulseaudio () 
{ 
    local cur prev words cword;
    local flags='-h --help --version --dump-conf --dump-resample-methods --cleanup-shm
                --start -k --kill --check --system= -D --daemonize= --fail= --high-priority=
                --realtime= --disallow-module-loading= --disallow-exit= --exit-idle-time=
                --scache-idle-time= --log-level= -v --log-target= --log-meta= --log-time=
                --log-backtrace= -p --dl-search-path= --resample-method= --use-pit-file=
                --no-cpu-limit= --disable-shm= -L --load= -F --file= -C -n';
    _init_completion -n = || return;
    case $cur in 
        --system=* | --daemonize=* | --fail=* | --high-priority=* | --realtime=* | --disallow-*=* | --log-meta=* | --log-time=* | --use-pid-file=* | --no-cpu-limit=* | --disable-shm=*)
            cur=${cur#*=};
            COMPREPLY=($(compgen -W 'true false' -- "$cur"))
        ;;
        --log-target=*)
            cur=${cur#*=};
            COMPREPLY=($(compgen -W 'auto syslog stderr file: newfile:' -- "$cur"))
        ;;
        --log-level=*)
            cur=${cur#*=};
            COMPREPLY=($(compgen -W '{0..4}' -- "$cur"))
        ;;
        --dl-search-path=*)
            cur=${cur#*=};
            _filedir -d
        ;;
        --file=*)
            cur=${cur#*=};
            _filedir
        ;;
        --resample-method=*)
            cur=${cur#*=};
            comps=$(__resample_methods);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        --load=*)
            cur=${cur#*=};
            comps=$(__all_modules);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
        --*=*)

        ;;
        -*)
            COMPREPLY=($(compgen -W '${flags[*]}' -- "$cur"));
            [[ $COMPREPLY == *= ]] && compopt -o nospace
        ;;
    esac;
    case $prev in 
        -D)
            COMPREPLY=($(compgen -W 'true false' -- "$cur"))
        ;;
        -p)
            _filedir -d
        ;;
        -F)
            _filedir
        ;;
        -L)
            cur=${cur#*=};
            comps=$(__all_modules);
            COMPREPLY=($(compgen -W '${comps[*]}' -- "$cur"))
        ;;
    esac
}
_pygmentize () 
{ 
    local cur prev;
    COMPREPLY=();
    cur=`_get_cword`;
    prev=${COMP_WORDS[COMP_CWORD-1]};
    case "$prev" in 
        -f)
            FORMATTERS=`pygmentize -L formatters | grep '* ' | cut -c3- | sed -e 's/,//g' -e 's/:$//'`;
            COMPREPLY=($( compgen -W '$FORMATTERS' -- "$cur" ));
            return 0
        ;;
        -l)
            LEXERS=`pygmentize -L lexers | grep '* ' | cut -c3- | sed -e 's/,//g' -e 's/:$//'`;
            COMPREPLY=($( compgen -W '$LEXERS' -- "$cur" ));
            return 0
        ;;
        -S)
            STYLES=`pygmentize -L styles | grep '* ' | cut -c3- | sed s/:$//`;
            COMPREPLY=($( compgen -W '$STYLES' -- "$cur" ));
            return 0
        ;;
    esac;
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($( compgen -W '-f -l -S -L -g -O -P -F \
                                   -N -H -h -V -o' -- "$cur" ));
        return 0;
    fi
}
_quote_readline_by_ref () 
{ 
    if [ -z "$1" ]; then
        printf -v $2 %s "$1";
    else
        if [[ $1 == \'* ]]; then
            printf -v $2 %s "${1:1}";
        else
            if [[ $1 == ~* ]]; then
                printf -v $2 ~%q "${1:1}";
            else
                printf -v $2 %q "$1";
            fi;
        fi;
    fi;
    [[ ${!2} == *\\* ]] && printf -v $2 %s "${1//\\\\/\\}";
    [[ ${!2} == \$* ]] && eval $2=${!2}
}
_realcommand () 
{ 
    type -P "$1" > /dev/null && { 
        if type -p realpath > /dev/null; then
            realpath "$(type -P "$1")";
        else
            if type -p greadlink > /dev/null; then
                greadlink -f "$(type -P "$1")";
            else
                if type -p readlink > /dev/null; then
                    readlink -f "$(type -P "$1")";
                else
                    type -P "$1";
                fi;
            fi;
        fi
    }
}
_rl_enabled () 
{ 
    [[ "$( bind -v )" = *$1+([[:space:]])on* ]]
}
_root_command () 
{ 
    local PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin;
    local root_command=$1;
    _command
}
_service () 
{ 
    local cur prev words cword;
    _init_completion || return;
    [[ $cword -gt 2 ]] && return 0;
    if [[ $cword -eq 1 && $prev == ?(*/)service ]]; then
        _services;
        [[ -e /etc/mandrake-release ]] && _xinetd_services;
    else
        local sysvdirs;
        _sysvdirs;
        COMPREPLY=($( compgen -W '`sed -e "y/|/ /" \
            -ne "s/^.*\(U\|msg_u\)sage.*{\(.*\)}.*$/\2/p" \
            ${sysvdirs[0]}/${prev##*/} 2>/dev/null` start stop' -- "$cur" ));
    fi
}
_services () 
{ 
    local sysvdirs;
    _sysvdirs;
    local restore_nullglob=$(shopt -p nullglob);
    shopt -s nullglob;
    COMPREPLY=($( printf '%s\n' ${sysvdirs[0]}/!($_backup_glob|functions) ));
    $restore_nullglob;
    COMPREPLY+=($( systemctl list-units --full --all 2>/dev/null |         awk '$1 ~ /\.service$/ { sub("\\.service$", "", $1); print $1 }' ));
    COMPREPLY=($( compgen -W '${COMPREPLY[@]#${sysvdirs[0]}/}' -- "$cur" ))
}
_shells () 
{ 
    local shell rest;
    while read -r shell rest; do
        [[ $shell == /* && $shell == "$cur"* ]] && COMPREPLY+=($shell);
    done 2> /dev/null < /etc/shells
}
_signals () 
{ 
    local -a sigs=($( compgen -P "$1" -A signal "SIG${cur#$1}" ));
    COMPREPLY+=("${sigs[@]/#${1}SIG/${1}}")
}
_split_longopt () 
{ 
    if [[ "$cur" == --?*=* ]]; then
        prev="${cur%%?(\\)=*}";
        cur="${cur#*=}";
        return 0;
    fi;
    return 1
}
_sysvdirs () 
{ 
    sysvdirs=();
    [[ -d /etc/rc.d/init.d ]] && sysvdirs+=(/etc/rc.d/init.d);
    [[ -d /etc/init.d ]] && sysvdirs+=(/etc/init.d);
    [[ -f /etc/slackware-version ]] && sysvdirs=(/etc/rc.d)
}
_terms () 
{ 
    COMPREPLY+=($( compgen -W         "$( sed -ne 's/^\([^[:space:]#|]\{2,\}\)|.*/\1/p' /etc/termcap             2>/dev/null )" -- "$cur" ));
    COMPREPLY+=($( compgen -W "$( { toe -a 2>/dev/null || toe 2>/dev/null; }         | awk '{ print $1 }' | sort -u )" -- "$cur" ))
}
_tilde () 
{ 
    local result=0;
    if [[ $1 == \~* && $1 != */* ]]; then
        COMPREPLY=($( compgen -P '~' -u "${1#\~}" ));
        result=${#COMPREPLY[@]};
        [[ $result -gt 0 ]] && compopt -o filenames 2> /dev/null;
    fi;
    return $result
}
_ufw () 
{ 
    cur=${COMP_WORDS[COMP_CWORD]};
    prev=${COMP_WORDS[COMP_CWORD-1]};
    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=($( compgen -W "$(_ufw_commands)" $cur ));
    else
        if [ $COMP_CWORD -eq 2 ]; then
            case "$prev" in 
                app)
                    COMPREPLY=($( compgen -W "$(_ufw_app_commands)" $cur ))
                ;;
                status)
                    COMPREPLY=($( compgen -W "$(_ufw_status_commands)" $cur ))
                ;;
                delete)
                    COMPREPLY=($( compgen -W "$(_ufw_rule_commands)" $cur ))
                ;;
                logging)
                    COMPREPLY=($( compgen -W "$(_ufw_logging_commands)" $cur ))
                ;;
                show)
                    COMPREPLY=($( compgen -W "$(_ufw_show_commands)" $cur ))
                ;;
                default)
                    COMPREPLY=($( compgen -W "$(_ufw_default_commands)" $cur ))
                ;;
            esac;
        fi;
    fi
}
_ufw_app_commands () 
{ 
    ufw --help | sed -e '1,/^Application profile commands:/d' -e '/^ [^ ]/!d' -e 's/[ \t]\+app[ \t]\+\([a-z|]\+\)[ \t]\+.*/\1/g'
}
_ufw_commands () 
{ 
    commands=$(ufw --help | sed -e '1,/^Commands:/d' -e '/^Application profile commands:/Q' -e 's/^[ \t]\+\([a-z|]\+\)[ \t]\+.*/\1/g' -e 's/|/ /g' | uniq);
    echo "$commands app"
}
_ufw_default_commands () 
{ 
    echo "allow deny reject"
}
_ufw_logging_commands () 
{ 
    echo "off on low medium high full"
}
_ufw_rule_commands () 
{ 
    echo "`_ufw_default_commands` limit"
}
_ufw_show_commands () 
{ 
    echo "raw"
}
_ufw_status_commands () 
{ 
    echo "numbered verbose"
}
_uids () 
{ 
    if type getent &> /dev/null; then
        COMPREPLY=($( compgen -W '$( getent passwd | cut -d: -f3 )' -- "$cur" ));
    else
        if type perl &> /dev/null; then
            COMPREPLY=($( compgen -W '$( perl -e '"'"'while (($uid) = (getpwent)[2]) { print $uid . "\n" }'"'"' )' -- "$cur" ));
        else
            COMPREPLY=($( compgen -W '$( cut -d: -f3 /etc/passwd )' -- "$cur" ));
        fi;
    fi
}
_update_initramfs () 
{ 
    local cur prev valid_options;
    cur=$(_get_cword);
    prev=${COMP_WORDS[COMP_CWORD-1]};
    if [[ "$prev" == '-k' ]]; then
        _kernel_versions;
        COMPREPLY=($( compgen -W '${COMPREPLY[@]} all' -- "$cur" ));
        return;
    fi;
    valid_options=$( update-initramfs -h 2>&1 | 		sed -e '/^ -/!d;s/^ \(-\w\+\).*/\1/' );
    COMPREPLY=($( compgen -W "$valid_options" -- $cur ))
}
_upstart_events () 
{ 
    ( cd /etc/init && egrep --color=auto '^[[:space:]]*emits ' *.conf | cut -d: -f2- | sed 's/^[[:space:]]*emits //g' | tr ' ' '\n' | awk '{print $NF}' | grep --color=auto -v ^$ | sort -u )
}
_upstart_initctl () 
{ 
    _get_comp_words_by_ref cur prev;
    COMPREPLY=();
    case "$prev" in 
        start)
            COMPREPLY=($(compgen -W "-n --no-wait $(_upstart_startable_jobs)" -- ${cur}));
            return 0
        ;;
        stop)
            COMPREPLY=($(compgen -W "-n --no-wait $(_upstart_stoppable_jobs)" -- ${cur}));
            return 0
        ;;
        emit)
            COMPREPLY=($(compgen -W "-n --no-wait $(_upstart_events)" -- ${cur}));
            return 0
        ;;
        -i | --ignore-events)
            for cmd in check-config;
            do
                cwords=${COMP_WORDS[@]##};
                filtered_cwords=${COMP_WORDS[@]##${cmd}};
                if [ "$filtered_cwords" != "$cwords" ]; then
                    COMPREPLY=($(compgen -W "$(_upstart_jobs)" -- ${cur}));
                    return 0;
                fi;
            done
        ;;
        -e | --enumerate)
            for cmd in show-config;
            do
                cwords=${COMP_WORDS[@]##};
                filtered_cwords=${COMP_WORDS[@]##${cmd}};
                if [ "$filtered_cwords" != "$cwords" ]; then
                    COMPREPLY=($(compgen -W "$(_upstart_jobs)" -- ${cur}));
                    return 0;
                fi;
            done
        ;;
        reload | restart)
            COMPREPLY=($(compgen -W "-n --no-wait $(_upstart_stoppable_jobs)" -- ${cur}));
            return 0
        ;;
        status)
            COMPREPLY=($(compgen -W "$(_upstart_jobs)" -- ${cur}));
            return 0
        ;;
        check-config)
            COMPREPLY=($(compgen -W "-w --warn -i --ignore-events= $(_upstart_jobs)" -- ${cur}));
            return 0
        ;;
        show-config)
            COMPREPLY=($(compgen -W "-e --enumerate $(_upstart_jobs)" -- ${cur}));
            return 0
        ;;
        -n | --no-wait)
            for cmd in start stop restart emit;
            do
                cwords=${COMP_WORDS[@]##};
                filtered_cwords=${COMP_WORDS[@]##${cmd}};
                if [ "$filtered_cwords" != "$cwords" ]; then
                    case "$cmd" in 
                        start)
                            COMPREPLY=($(compgen -W "$(_upstart_startable_jobs)" -- ${cur}))
                        ;;
                        stop)
                            COMPREPLY=($(compgen -W "$(_upstart_stoppable_jobs)" -- ${cur}))
                        ;;
                        restart)
                            COMPREPLY=($(compgen -W "$(_upstart_stoppable_jobs)" -- ${cur}))
                        ;;
                        emit)
                            COMPREPLY=($(compgen -W "$(_upstart_events)" -- ${cur}))
                        ;;
                    esac;
                    return 0;
                fi;
            done
        ;;
        --help | --version)
            COMPREPLY=();
            return 0
        ;;
    esac;
    opts="--help --version -q --quiet -v --verbose --session --system --dest=";
    cmds=$(initctl help|grep "^  [^ ]"|awk '{print $1}');
    COMPREPLY=($(compgen -W "${opts} ${cmds}" -- ${cur}))
}
_upstart_jobs () 
{ 
    initctl list | awk '{print $1}' | sort -u
}
_upstart_reload () 
{ 
    COMPREPLY=();
    _get_comp_words_by_ref cur prev;
    opts="--help --version -q --quiet -v --verbose --session --system --dest=";
    case "$prev" in 
        --help | --version)
            COMPREPLY=();
            return 0
        ;;
    esac;
    COMPREPLY=($(compgen -W "$opts $(_upstart_stoppable_jobs)" -- ${cur}));
    return 0
}
_upstart_restart () 
{ 
    COMPREPLY=();
    _get_comp_words_by_ref cur prev;
    opts="--help --version -q --quiet -v --verbose --session --system --dest=         -n --no-wait";
    case "$prev" in 
        --help | --version)
            COMPREPLY=();
            return 0
        ;;
    esac;
    COMPREPLY=($(compgen -W "$opts $(_upstart_stoppable_jobs)" -- ${cur}));
    return 0
}
_upstart_start () 
{ 
    COMPREPLY=();
    _get_comp_words_by_ref cur prev;
    opts="--help --version -q --quiet -v --verbose --session --system --dest=         -n --no-wait";
    case "$prev" in 
        --help | --version)
            COMPREPLY=();
            return 0
        ;;
    esac;
    COMPREPLY=($(compgen -W "$opts $(_upstart_startable_jobs)" -- ${cur}));
    return 0
}
_upstart_startable_jobs () 
{ 
    initctl list | cut -d\, -f1 | awk '$2 == "stop/waiting" {print $1}'
}
_upstart_status () 
{ 
    COMPREPLY=();
    _get_comp_words_by_ref cur prev;
    opts="--help --version -q -d --detail -e --enumerate --quiet -v --verbose --session --system --dest=";
    case "$prev" in 
        --help | --version)
            COMPREPLY=();
            return 0
        ;;
    esac;
    COMPREPLY=($(compgen -W "$opts $(_upstart_jobs)" -- ${cur}));
    return 0
}
_upstart_stop () 
{ 
    COMPREPLY=();
    _get_comp_words_by_ref cur prev;
    opts="--help --version -q --quiet -v --verbose --session --system --dest=         -n --no-wait";
    case "$prev" in 
        --help | --version)
            COMPREPLY=();
            return 0
        ;;
    esac;
    COMPREPLY=($(compgen -W "$opts $(_upstart_stoppable_jobs)" -- ${cur}));
    return 0
}
_upstart_stoppable_jobs () 
{ 
    initctl list | cut -d\, -f1 | awk '$2 == "start/running" {print $1}'
}
_upvar () 
{ 
    if unset -v "$1"; then
        if (( $# == 2 )); then
            eval $1=\"\$2\";
        else
            eval $1=\(\"\${@:2}\"\);
        fi;
    fi
}
_upvars () 
{ 
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname" "value] | [-aN varname [value ...]] ..." 1>&2;
        return 2;
    fi;
    while (( $# )); do
        case $1 in 
            -a*)
                [[ -n ${1#-a} ]] || { 
                    echo "bash: ${FUNCNAME[0]}: \`$1': missing" "number specifier" 1>&2;
                    return 1
                };
                printf %d "${1#-a}" &> /dev/null || { 
                    echo "bash:" "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2;
                    return 1
                };
                [[ -n "$2" ]] && unset -v "$2" && eval $2=\(\"\${@:3:${1#-a}}\"\) && shift $((${1#-a} + 2)) || { 
                    echo "bash: ${FUNCNAME[0]}:" "\`$1${2+ }$2': missing argument(s)" 1>&2;
                    return 1
                }
            ;;
            -v)
                [[ -n "$2" ]] && unset -v "$2" && eval $2=\"\$3\" && shift 3 || { 
                    echo "bash: ${FUNCNAME[0]}: $1: missing" "argument(s)" 1>&2;
                    return 1
                }
            ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2;
                return 1
            ;;
        esac;
    done
}
_usb_ids () 
{ 
    COMPREPLY+=($( compgen -W         "$( PATH="$PATH:/sbin" lsusb | awk '{print $6}' )" -- "$cur" ))
}
_user_at_host () 
{ 
    local cur prev words cword;
    _init_completion -n : || return;
    if [[ $cur == *@* ]]; then
        _known_hosts_real "$cur";
    else
        COMPREPLY=($( compgen -u -- "$cur" ));
    fi;
    return 0
}
_usergroup () 
{ 
    if [[ $cur = *\\\\* || $cur = *:*:* ]]; then
        return;
    else
        if [[ $cur = *\\:* ]]; then
            local prefix;
            prefix=${cur%%*([^:])};
            prefix=${prefix//\\};
            local mycur="${cur#*[:]}";
            if [[ $1 == -u ]]; then
                _allowed_groups "$mycur";
            else
                local IFS='
';
                COMPREPLY=($( compgen -g -- "$mycur" ));
            fi;
            COMPREPLY=($( compgen -P "$prefix" -W "${COMPREPLY[@]}" ));
        else
            if [[ $cur = *:* ]]; then
                local mycur="${cur#*:}";
                if [[ $1 == -u ]]; then
                    _allowed_groups "$mycur";
                else
                    local IFS='
';
                    COMPREPLY=($( compgen -g -- "$mycur" ));
                fi;
            else
                if [[ $1 == -u ]]; then
                    _allowed_users "$cur";
                else
                    local IFS='
';
                    COMPREPLY=($( compgen -u -- "$cur" ));
                fi;
            fi;
        fi;
    fi
}
_userland () 
{ 
    local userland=$( uname -s );
    [[ $userland == @(Linux|GNU/*) ]] && userland=GNU;
    [[ $userland == $1 ]]
}
_variables () 
{ 
    if [[ $cur =~ ^(\$\{?)([A-Za-z0-9_]*)$ ]]; then
        [[ $cur == *{* ]] && local suffix=} || local suffix=;
        COMPREPLY+=($( compgen -P ${BASH_REMATCH[1]} -S "$suffix" -v --             "${BASH_REMATCH[2]}" ));
        return 0;
    fi;
    return 1
}
_xfunc () 
{ 
    set -- "$@";
    local srcfile=$1;
    shift;
    declare -F $1 &> /dev/null || { 
        local compdir=./completions;
        [[ $BASH_SOURCE == */* ]] && compdir="${BASH_SOURCE%/*}/completions";
        . "$compdir/$srcfile"
    };
    "$@"
}
_xinetd_services () 
{ 
    local xinetddir=/etc/xinetd.d;
    if [[ -d $xinetddir ]]; then
        local restore_nullglob=$(shopt -p nullglob);
        shopt -s nullglob;
        local -a svcs=($( printf '%s\n' $xinetddir/!($_backup_glob) ));
        $restore_nullglob;
        COMPREPLY+=($( compgen -W '${svcs[@]#$xinetddir/}' -- "$cur" ));
    fi
}
command_not_found_handle () 
{ 
    if [ -x /usr/lib/command-not-found ]; then
        /usr/lib/command-not-found -- "$1";
        return $?;
    else
        if [ -x /usr/share/command-not-found/command-not-found ]; then
            /usr/share/command-not-found/command-not-found -- "$1";
            return $?;
        else
            printf "%s: command not found\n" "$1" 1>&2;
            return 127;
        fi;
    fi
}
dequote () 
{ 
    eval printf %s "$1" 2> /dev/null
}
in_array () 
{ 
    local i;
    for i in "${@:2}";
    do
        [[ $1 = "$i" ]] && return;
    done
}
quote () 
{ 
    local quoted=${1//\'/\'\\\'\'};
    printf "'%s'" "$quoted"
}
quote_readline () 
{ 
    local quoted;
    _quote_readline_by_ref "$1" ret;
    printf %s "$ret"
}
