fun! jumpy#map(pattern, force) abort
	" Otherwise in Markdown the HTML mappings will override.
	if !a:force && mapcheck('[[', 'n') isnot# ''
		return
	endif

	for l:mode in ['n', 'o', 'x']
		exe printf('%snoremap <buffer> <silent> ]] :<C-u>call jumpy#jump("%s", "%s", "next")<CR>',
					\ l:mode, fnameescape(a:pattern), l:mode)
		exe printf('%snoremap <buffer> <silent> [[ :<C-u>call jumpy#jump("%s", "%s", "prev")<CR>',
					\ l:mode, fnameescape(a:pattern), l:mode)
	endfor
endfun

fun! jumpy#jump(pattern, mode, dir) abort
	" Get motion count; done here as some commands later on will reset it.
	" -1 because the index starts from 0 in motion.
	let l:count = v:count1

	" Set context mark so user can jump back with '' or ``.
	normal! m'

	" Start visual selection or re-select previously selected.
	if a:mode is# 'x'
		normal! gv
	endif

	let l:save = winsaveview()
	for l:i in range(l:count)
		let l:loc = search(a:pattern, 'W' . (a:dir is# 'prev' ? 'b' : ''))
		if l:loc > 0
			continue
		endif

		" Jump to top or bottom of file if we're at the first or last match.
		if l:i is l:count - 1
			exe 'keepjumps normal! ' . (a:dir is# 'next' ? 'G' : 'gg')
		else
			call winrestview(l:save)
		endif

		break
	endfor
endfun

" Run a test case.
fun! jumpy#test(filename, testcase) abort
	new
	call setline(1, map(copy(a:testcase), {_, t -> l:t[1]}))
	silent exe 'w ' . a:filename
	silent e

	normal! gg
	let l:want = 0
	for l:skip in map(copy(a:testcase), {_, t -> l:t[0]})
		let l:want += 1
		if l:skip is 0
		  continue
		endif

		" vint: -ProhibitCommandRelyOnUser
		normal ]]
		if l:want isnot line('.')
			call Errorf('want: %d; got: %d for: %s', l:want, line('.'), getline('.'))
		endif
	endfor
endfun
