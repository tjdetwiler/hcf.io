#
#  Copyright(C) 2012, Tim Detwiler <timdetwiler@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This software is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this software.  If not, see <http://www.gnu.org/licenses/>.
#
#= require hcf
#= require codemirror/codemirror
#= require codemirror/keymap/vim
#= require codemirror/mode/dasm
#

Dcpu16          = hcf.Dcpu16
Disasm          = hcf.Disasm
Assembler       = hcf.Assembler
JobLinker       = hcf.JobLinker
Lem1802         = hcf.Hw.Lem1802
GenericClock    = hcf.Hw.GenericClock
GenericKeyboard = hcf.Hw.GenericKeyboard

class File
  constructor: (name) ->
    @mText = ""
    @mName = name

    id = name.split(".").join("_")
    # Add to project file listing
    $('#projFiles').append(
      "<li><a href='#'><i class='icon-file file-close'></i>#{name}</a></li>")

    # Add to file tabs
    link = $("<a href='#openFile-#{id}' data-toggle='tab'>#{name}<i class='icon-remove'></i></a>")
    node =  $("<li></li>").append link
    $('#openFiles').append node
    $("#openFiles a").click (e) ->
      e.preventDefault()
      $(this).tab 'show'

    # Create Editor
    editor = $("<textarea id='tmp'></textarea>")[0]
    pane = $("<div id='openFile-#{id}' class='tab-pane'></div>")
    pane.append editor
    $('#openFileContents').append pane[0]

    @mEditor = CodeMirror.fromTextArea(editor, {
      lineNumbers: true
      mode: "text/x-dasm"
      keyMap: "vim"
      onGutterClick: (cm,n,e) ->
        info = cm.lineInfo n
        if info.markerText
          cm.clearMarker n
        else
          cm.setMarker n, "<span style='color: #900'>●</span> %N%"
    })

    $(".file-close").click () -> alert "oh hey"
    link.click()
    @mEditor.refresh()


  text: (val) ->
    if val?
      @mEditor.setValue val
    else
      @mEditor.getValue()
  name: () -> @mName
  editor: () -> @mEditor

class DcpuWebapp
  constructor: () ->
    @mAsm = null
    @mRunTimer = null
    @mRunning = false
    @mFiles = []
    @mInstrCount = 0
    @mLoopCount = 0
    @mRegs = [
      ($ "#RegA"),
      ($ "#RegB"),
      ($ "#RegC"),
      ($ "#RegX"),
      ($ "#RegY"),
      ($ "#RegZ"),
      ($ "#RegI"),
      ($ "#RegJ"),
      ($ "#RegPC"),
      ($ "#RegSP"),
      ($ "#RegEX")]
    @mCpu = new Dcpu16()
    @setupCPU()
    @setupCallbacks()
    @updateCycles()
    @updateRegs()
    @dumpMemory()
    @mCreateDialog = $("#newFile").modal {
      show: false }
    @mCreateDialog.hide()
    @assemble()

  addFile: (name, content) ->
    f = new File name
    f.text content
    @mFiles.push f
    @mFiles[f.name()] = f

  #
  # Refresh the Register Output
  #
  updateRegs: () ->
    for v,i in @mRegs
      v.html('0x'+Disasm.fmtHex @mCpu.readReg(i))

  #
  # Refresh the Cycle-Count Output
  #
  updateCycles: () -> $("#cycles").html "#{@mCpu.mCycles}"

  #
  # Refresh the Memory-Dump Output
  #
  dumpMemory: () ->
    base = $("#membase").val()
    base = 0 if not base
    base = parseInt base
    body = $ "#memdump-body"
    body.empty()
    for r in [0..4]
      row = $ "<tr><td>#{Disasm.fmtHex base + (r*8)}</td></tr>"

      for c in [0..7]
        v = @mCpu.readMem base + (r*8) + c
        html = "<td>#{Disasm.fmtHex v}</td>"
        col = $ html
        row.append col
      body.append row

  #
  # Displays an error message on the page.
  #
  error: (msg) -> $("#asm-error").html msg

  #
  # Load text from UI, assemble it, and load it into the CPU.
  #
  assemble: () ->
    @save()
    jobs = []
    for file in @mFiles
      @mAsm = new Assembler()
      jobs.push @mAsm.assemble file.text(), file.name()
    exe = JobLinker.link jobs
    console.log exe
    @mCpu.loadJOB exe
    @mCpu.regPC 0
    @dumpMemory()
    @updateRegs()

  runStop: () ->
    if @mRunning
      @stop()
    else
      @run()

  run: () ->
    @mRunning = true
    @mCpu.run()
    $("#btnRun").html "<i class='icon-stop'></i>Stop"

  stop: () ->
    @mCpu.stop()
    @mRunning = false
    $("#btnRun").html "<i class='icon-play'></i>Run"

  step: () ->
    @mCpu.step()
    @updateRegs()
    @updateCycles()
    i = @mCpu.next()
    info = @mCpu.addr2line i.addr()
    editor = @mFiles[info.file].editor()
    if @mActiveLine?
      @mFiles[@mActiveLine.file].editor().setLineClass(@mActiveLine.line, null, null)
    editor.setLineClass(info.line, null, "activeline")
    @mActiveLine = {file: info.file, line: info.line}

  #
  # Resets the CPU and the UI
  #
  reset: () ->
    @stop()
    @mCpu.reset()
    @assemble()
    @updateCycles()

  create: (f) ->
    file = new File f
    @mFiles.push file
    @mFiles[f] = file
    @mCreateDialog.modal "toggle"

  #
  # Init CPU and Devices
  #
  setupCPU: () ->
    # Setup Devices
    app = @
    lem = new Lem1802 @mCpu, $("#framebuffer")[0]
    lem.mScale = 4
    @mCpu.addDevice lem
    @mCpu.addDevice new GenericClock @mCpu
    @mCpu.addDevice new GenericKeyboard @mCpu
    @mCpu.onPeriodic (_) ->
      app.updateRegs()
      app.updateCycles()

  #
  # Wire up DOM event callbacks.
  #
  setupCallbacks: () ->
    app = this
    $("#membase").change () ->
      base = $("#membase").val()
      base = 0 if not base
      app.dumpMemory parseInt base
    $("#btnRun").click () -> app.runStop()
    $("#btnStop").click () -> app.runStop()
    $("#btnStep").click () -> app.step()
    $("#btnReset").click () -> app.reset()
    $("#btnAssemble").click () -> app.assemble()

  saveFile: (f) ->
    console.log "saving #{f.name()}"
    data = JSON.stringify {name: f.name(), code: f.text()}
    console.log "Sending <#{data}>"
    $.ajax {
      type: "put",
      url: "/projects/" + projId + "/files/" + f.name() + ".json",
      contentType: "application/json",
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      },
      data: data,
      success: () -> alert("Great Success"),
      error: (a,b,c) ->
        console.log a
        console.log b
        console.log c
    }

  save: ()  ->
    for k,v in @mFiles
      console.log k
      if isNaN k
        @saveFile k

#
# On Load
#
$ () ->
  window.app = new DcpuWebapp()

