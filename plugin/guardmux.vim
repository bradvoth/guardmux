"if exists('g:loaded_guardmux') 
" finish
"ndif
"et g:loaded_guardmux = 1
" '-h' for horizontal split window
" '-v' for vertical split window
let g:guardmux_split = get(g:, 'guardmux_split', '-v')
let g:guardmux_size  = get(g:, 'guardmux_size',  '10')

command! -nargs=0 GmuxToggle       call Guardmux_toggle()
nnoremap <silent> <leader>g :GmuxToggle<cr>

function! Guardmux_toggle()
  if !exists('$TMUX')
    echomsg 'guardmux: This Vim is not running in a tmux session!'
    return
  endif
  call Guardmux_dangling()
  if !exists('g:guardmux_pane') 
    call Guardmux_create_pane()
    return
  endif
  let curwin = Guardmux_get_current_window()
  let location = Guardmux_get_location()
  if curwin == location
    call Guardmux_to_bg()
  else
    call Guardmux_to_fg()
  end
endfunction

function! Guardmux_get_location()
  return system('tmux display-message -p -t '. g:guardmux_pane .' "#I"')
endfunction

function! Guardmux_to_bg()
  call system('tmux break-pane -Pd -t '. g:guardmux_pane)
endfunction

function! Guardmux_to_fg()
  call system('tmux join-pane -d -s '. g:guardmux_pane)
endfunction

function! Guardmux_get_current_window()
  return system('tmux display-message -p "#I"')
endfunction

function! Guardmux_dangling()
  if !exists('g:guardmux_pane') 
    return
  endif
  call system('tmux display-message -p -t '. g:guardmux_pane .' "#D"')
  if v:shell_error
    call Guardmux_clear()
  endif
endfunction

function! Guardmux_clear()
  unlet g:guardmux_pane
endfunction

function! Guardmux_create_pane()
  let g:guardmux_pane = substitute(system('tmux split-window -Pd -F "#D" "source ~/.bash_profile ; guard -l 1"'), '\n$', '', '')
  echom g:guardmux_pane
endfunction
