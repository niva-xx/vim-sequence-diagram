vim9script
# NiVa 2020/12/21 Vim9script Version

export def Generate_diagram(pluginPath: string)
  var buf: list<string> = getline(1, '$')
  #for substitute here needs 4 backslashs, but remember it's inside of double
  #quota string, so actually 8 backslashs literally
  call map(buf, 'substitute' .. "(v:val, '\\', '\\\\\\\\', 'g')")
  call map(buf, 'substitute' .. "(v:val, '`', '\\\\`', 'g')")

  var tmpl: string = pluginPath .. '/tmpl.html'


  var tmpDir: string = ''
  if has('win32')
   tmpDir = expand('$tmp/vim-js-seq/')
   call mkdir(tmpDir, 'p', 0777)
  else
   tmpDir = '/tmp/vim-js-seq/'
   call system('mkdir ' .. tmpDir)
  endif

  #TODO check file already exists?
  if has('win32')
	call system('copy /Y '  .. pluginPath .. 'underscore-min.js'       .. ' ' .. tmpDir)
	call system('copy /Y '  .. pluginPath .. 'raphael-min.js'          .. ' ' .. tmpDir)
	call system('copy /Y '  .. pluginPath .. 'sequence-diagram-min.js' .. ' ' .. tmpDir)
	call system('copy /Y '  .. pluginPath .. 'browser.min.js'          .. ' ' .. tmpDir)
    call system('copy /Y "' .. pluginPath .. 'tmpl.html"'       .. ' "' .. tmpDir .. 'out.html"')
  else
	call system('cp '       .. pluginPath .. 'underscore-min.js'       .. ' ' .. tmpDir)
	call system('cp '       .. pluginPath .. 'raphael-min.js'          .. ' ' .. tmpDir)
	call system('cp '       .. pluginPath .. 'sequence-diagram-min.js' .. ' ' .. tmpDir)
	call system('cp '       .. pluginPath .. 'browser.min.js'          .. ' ' .. tmpDir)
  endif

  var out: string = tmpDir .. "out.html"

  var originTab: number = tabpagenr()
  execute "tabe " .. out
  #append the theme first to avoid the position of placeholder changes
  if g:generate_diagram_theme_hand == 1
    call append(17, ["'hand'"])
  else
    call append(17, ["'simple'"])
  endif
  
  #append buffer content
  call append(15, buf)
  silent :w!
  :bd
  execute "tabn " .. originTab 
  
  if has('mac')
    call system("osascript " .. pluginPath .. '/applescript/active.scpt')
  elseif has('unix')
    call system("xdg-open " .. out)
  elseif has('win32')
    call Vim_Seq_OpenUrl('file:///' .. out)
  endif
enddef

def Vim_Seq_OpenUrl(url: string): void

  echomsg url
  var filteredUrl: string = url->split()->filter(' v:val =~ ''\(\(ht\|f\)tp\|file\)'' ')->join()
  echomsg filteredUrl

  g:job = job_start( 'rundll32 url.dll,FileProtocolHandler ' .. filteredUrl, {
		\ out_cb:   function( 'g:Vim_Seq_Job_cb',  ['g:Vim_Seq_Job_out_cb',  {} ] ),
		\ out_mode: 'raw'
		\})

enddef
def! g:Vim_Seq_Job_cb(fn: string, job: job, ch: channel, data: string)
	call(fn, [job, data])
enddef
def g:Vim_Seq_Job_out_cb(self: job, data: string)

	var idx   =  1
	var data .= string(g:idx)
	var data .= a:data

	var self  = a:self

	try
		data  = remove(self.lines, -1) . data
	catch /.*/
		echomsg 'begin'.string(data).'end'	
	endtry

	lines = split( data, "\n", 1)

	call extend(self.lines, lines)

enddef
