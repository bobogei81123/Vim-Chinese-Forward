
function! Init()

    if g:dictionary_file == ''
        return
    endif
    let s:dict_file = readfile(g:dictionary_file)
    let s:dict = {}
    for s:line in s:dict_file
        let [s:key, s:val] = split(s:line)
        let s:dict[s:key] = s:val[0]
    endfor
    for i in range(32, 127)
        let s:dict[nr2char(i)] = nr2char(i)
    endfor

    noremap f :<C-U>call Forward(0, 1, v:count)<CR>
    noremap F :<C-U>call Forward(0, -1, v:count)<CR>
    noremap t :<C-U>call Forward(1, 1, v:count)<CR>
    noremap T :<C-U>call Forward(1, -1, v:count)<CR>
    noremap ; :<C-U>call Repeat_forward(1)<CR>
    noremap , :<C-U>call Repeat_forward(-1)<CR>

    let s:last_target = ''
    let s:last_dir = 0
    let s:last_cnt = 0
    let s:last_is_till = 0

endfunction

function! Forward(is_till, dir, cnt)
    let cnt = (a:cnt == 0 ? 1 : a:cnt)
    let target = nr2char(getchar())
    let cur_pos = col('.')
    let line = getline('.')
    let res = s:Search(line, cur_pos+a:dir, a:dir, target, cnt)
    let s:last_target = target
    let s:last_dir = a:dir
    let s:last_cnt = cnt
    let s:last_is_till = a:is_till
    if res == -1
        normal \<Esc>
        return
    endif
    let res -= a:is_till * a:dir
    let res = max([res, 1])
    call cursor(line('.'), res)
endfunction

function! Repeat_forward(dir)
    if s:last_target == ''
        return
    endif
    let real_dir = a:dir * s:last_dir
    let cur_pos = col('.')
    let next_pos = cur_pos + real_dir + s:last_is_till * real_dir
    let res = s:Search(getline('.'), next_pos, real_dir, s:last_target, s:last_cnt)
    if res == -1
        normal \<Esc>
        return
    endif 
    let res -= s:last_is_till * s:last_dir
    let res = max([res, 1])
    call cursor(line('.'), res)
endfunction
    


function! s:Search(str, cur_pos, dir, target, cnt)
    let cnt = a:cnt
    let len = strlen(a:str)
    let cur_pos = a:cur_pos
    while cur_pos <= len && cur_pos > 0
        let cur_char = matchstr(a:str, '\%' . cur_pos . 'c.')
        if cur_char != '' && s:dict[cur_char][0] == a:target
            let cnt -= 1
        endif
        if cnt == 0
            return cur_pos
        endif

        let cur_pos += a:dir
    endwhile
    return -1
endfunction

call Init()

"不會你真的啊啊也也耶耶
