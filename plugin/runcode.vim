command! -nargs=* RitCommand call <SID>RitCommand(<f-args>)
command! -nargs=* RitCurrentFile call <SID>RitCurrentFile(<f-args>)
command! RitClose call <SID>RitClose()
command! -nargs=* OpenTmuxPane call <SID>OpenTmuxPane(<f-args>)

function! s:GetPaneSize()
	if exists('g:RitPaneSize')
		return g:RitPaneSize
	else
		return 25
	endif
endfunction

" the argument is autoreturn
" 1 : autoreturn
" 0 : not auto return
function! s:OpenTmuxPane(autoreturn)
	call system('tmux split-window -v -p ' . <SID>GetPaneSize())
	let g:RitPaneIndex = substitute(system('tmux display -p "#I.#P"'), '\n$', '', '')
	" echo strlen(g:RitPaneIndex)

	if a:autoreturn == 1
		call system('tmux last-pane')
	endif
endfunction

function! s:RitClose()
	call system('tmux kill-pane -t ' . g:RitPaneIndex)
	unlet g:RitPaneIndex
endfunction

" function! s:RunTmuxCommand(command)
"     call system('tmux ' . a:command)
" endfunction

function! s:SendToTmux(text)
	call system('tmux send-keys -t ' . g:RitPaneIndex . " " . a:text)
endfunction

function! s:CheckPaneExists(pane_id)
	return system('tmux list-panes -s -F "#I.#P" | grep ' . a:pane_id)
endfunction

function! s:RitCommand(command, autoreturn)
	if !exists("g:RitPaneIndex") || !<SID>CheckPaneExists(g:RitPaneIndex)
		call <SID>OpenTmuxPane(a:autoreturn)
	endif
	call <SID>SendToTmux("q C-u")
	call <SID>SendToTmux(a:command)
	call <SID>SendToTmux("Enter")
endfunction

function! s:RitCurrentFile(language, autoreturn)
	if !exists("g:RitPaneIndex") || !<SID>CheckPaneExists(g:RitPaneIndex)
		call <SID>OpenTmuxPane(a:autoreturn)
	endif
	call <SID>SendToTmux("q C-u")
	" echo a:language . " " . '123'
	call <SID>SendToTmux('"' . a:language . " " . expand("%:p") . '"')
	call <SID>SendToTmux("Enter")
endfunction
