" haskell-ide-engine.vim - Vim bindings
" Maintainer: Griffin Smith <wildgriffin45 at gmail dot com>
" Version:    0.1

" Initialization {{{

if exists('g:loaded_hie') || &cp
  finish
endif
let g:loaded_hie = 1

if !exists('g:hie_executable')
  let g:hie_executable = 'hie'
endif

if !exists('g:hie_debug')
  let g:hie_debug = 0
endif

" }}}

" Output {{{
function! s:warn(message)
  echohl WarningMsg
  echo a:message
  echohl None
endfunction

function! s:info(message)
  echo a:message
endfunction

function! s:dbg(message)
  if g:hare_debug
    echom a:message
  endif
endfunction
" }}}

" Converting to JSON {{{
function! s:to_json(val) abort
  python << endpython
import json
import vim

def to_list(vim_list):
  rv = []
  for i in vim_list:
    rv.append(to_python(i))
  return rv

def to_dict(vim_dictionary):
  rv = {}
  for k, v in vim_dictionary.items():
    rv[k] = to_python(v)
  return rv

def to_python(val):
  if isinstance(val, vim.Dictionary):
    return to_dict(val)
  elif isinstance(val, vim.List):
    return to_list(val)
  else:
    return val

val = vim.bindeval('a:val')
json_val = json.dumps(to_python(val))
endpython

  let result =  pyeval('json_val')
  return result

endfunction
" }}}

" Running HIE {{{

function! HieCommand(plugin, cmd, params) abort
  let json = s:to_json({ 'cmd': a:plugin . ':' . a:cmd, 'params': a:params })
  let raw_result = system(g:hie_executable . ' --one-shot', json)
  let result = eval(substitute(raw_result, '\%x2', '', 'e'))
  if v:shell_error ==? 0
    return result
  else
    call warn(result)
  endif
endfunction

" }}}

" vim:sw=2 et tw=80 fdm=marker fmr={{{,}}}:
