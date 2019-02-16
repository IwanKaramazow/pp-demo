module Gl = {
  @bs.deriving(abstract)
  type t = {
    @bs.as("COLOR_BUFFER_BIT") color_buffer_bit: int,
    @bs.as("ARRAY_BUFFER") array_buffer: int,
    @bs.as("STATIC_DRAW") static_draw: int,
    @bs.as("DYNAMIC_DRAW") dynamic_draw: int,
    @bs.as("STREAM_DRAW") stream_draw: int,
    @bs.as("FLOAT") float: int,
    @bs.as("TRIANGLES") triangles: int,
    @bs.as("LINK_STATUS") link_status: int,
    @bs.as("VERTEX_SHADER") vertex_shader: int,
    @bs.as("FRAGMENT_SHADER") fragment_shader: int
  }

  type webGlBuffer;
  type webGlProgram;
  type webGlShader;

  @bs.send
  external attachShader: (t, ~program: webGlProgram, ~shader: webGlShader) => unit = ""

  @bs.send
  external linkProgram: (t, ~program: webGlProgram) => unit = ""
  @bs.send
  external useProgram: (t, ~program: webGlProgram) => unit = ""
  @bs.send
  external createProgram: (t, unit) => webGlProgram = ""

  @bs.send
  external createBuffer : (t, unit) => webGlBuffer = ""

  @bs.send
  external createShader: (t, int) => webGlShader = ""

  @bs.send
  external compileShader: (t, ~shader: webGlShader) => unit = ""

  @bs.send
  external shaderSource: (t, ~shader: webGlShader, ~source: string) => unit = ""

  @bs.send
  external bindBuffer : (t, ~target: int, ~buffer: webGlBuffer) => unit = ""

  @bs.send
  external clearColor : (t, float, float, float, float) => unit = ""

  @bs.send
  external clear : (t, int) => unit = ""

  @bs.send
  external bufferData : (t, ~target:int, ~srcData:'a, ~usage:int) => unit = ""

  @bs.send
  external bufferDataWithSize : (t, ~target:int, ~size:int, ~usage:int) => unit = ""

  @bs.send
  external enableVertexAttribArray : (t, int) => unit = ""

  @bs.send
  external disableVertexAttribArray: (t, int) => unit = ""

  @bs.send
  external vertexAttribPointer: (
    t,
    // A GLuint specifying the index of the vertex attribute that is to be modified.
    ~index: int,
    // A GLint specifying the number of components per vertex attribute. Must be 1, 2, 3, or 4.
    ~size: int,
    // A GLenum specifying the data type of each component in the array
    ~type_: int,
    // A GLboolean specifying whether integer data values should be normalized into a certain range when being casted to a float.
    ~normalized: bool,
    // A GLsizei specifying the offset in bytes between the beginning of consecutive vertex attributes
    ~stride: int,
    // A GLintptr specifying an offset in bytes of the first component in the vertex attribute array.
    ~offset: int
  ) => unit = ""

  @bs.send
  external drawArrays: (t, ~mode: int, ~first: int, ~count: int) => unit = ""

  /* GLenum	unsigned long */
  type glEnum = int
}

module Document = {
  @bs.scope("document") @bs.val
  external getElementById : string => Js.Nullable.t<Dom.element> = ""

  @bs.send
  external getContext: (Dom.element, string) => Js.Nullable.t<Gl.t> = ""
}

let initializeVertexBuffer = (gl: Gl.t) => {
  let vertexPositions = [
    0.75, 0.75, 0., 1.,
    0.75, -0.75, 0., 1.,
    -0.75, -0.75, 0., 1.,
  ]

  // create buffer object
  let buffer = gl->Gl.createBuffer()

  // bind created buffer object to GL_ARRAY_BUFFER
  gl->Gl.bindBuffer(~target=gl->Gl.array_bufferGet, ~buffer)

  /*
    1) allocate memory for the currently bound buffer (bound to GL_ARRAY_BUFFER)
    2) copy data from our memory array into the buffer object
  */
  gl->Gl.bufferData(
    ~target=gl->Gl.array_bufferGet,
    ~srcData=Js.Typed_array.Float32Array.make(vertexPositions),
    ~usage=gl->Gl.static_drawGet
  )

  buffer
}

let vertexShaderString = `
  attribute vec4 position;
  void main() {
    gl_Position = position;
  }
`

let fragmentShaderString = `
  void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.1);
  }
`

let createShaders = (gl: Gl.t) => {
  let vertexShader = gl->Gl.createShader(gl->Gl.vertex_shaderGet)
  gl->Gl.shaderSource(~shader=vertexShader, ~source=vertexShaderString)
  gl->Gl.compileShader(~shader=vertexShader)

  let fragmentShader = gl->Gl.createShader(gl->Gl.fragment_shaderGet)
  gl->Gl.shaderSource(~shader=fragmentShader, ~source=fragmentShaderString)
  // TODO: we need the semi explicitly here…
  gl->Gl.compileShader(~shader=fragmentShader);

  /vertexShader, fragmentShader/
}

let q = Document.getElementById("canvas")

switch q->Js.Nullable.toOption {
| Some(node) =>
  let gl = node->Document.getContext("webgl")

  switch gl->Js.Nullable.toOption {
  | Some(gl) =>
    let program = gl->Gl.createProgram()

    let /vertexShader, fragmentShader/ = createShaders(gl)
    gl->Gl.attachShader(~program, ~shader=vertexShader)
    gl->Gl.attachShader(~program, ~shader=fragmentShader)

    gl->Gl.linkProgram(~program)
    gl->Gl.useProgram(~program)

    let buffer = initializeVertexBuffer(gl)

    gl->Gl.clearColor(0., 0., 0., 1.)
    gl->Gl.clear(gl->Gl.color_buffer_bitGet)

    gl->Gl.bindBuffer(~target=gl->Gl.array_bufferGet, ~buffer)
    gl->Gl.enableVertexAttribArray(0)
    gl->Gl.vertexAttribPointer(
      ~index=0,
      ~size=4,
      ~type_=gl->Gl.floatGet,
      ~normalized=false,
      ~stride=0,
      ~offset=0,
    )

    gl->Gl.drawArrays(~mode=gl->Gl.trianglesGet, ~first=0, ~count=3)

    gl->Gl.disableVertexAttribArray(0)

  | None =>
    Js.log("no webgl available");
  }

| None => ()
}
