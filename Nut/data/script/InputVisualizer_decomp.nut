this.text <- null
this.obj <- []
this.inputs <- []

function PrintInput(input){
	local text = ::font.CreateSystemString(input);
	this.text = text;
	this.text.ConnectRenderSlot(::graphics.slot.info, 1000);
	this.text.x = 100.0;
	this.text.y = 500.0;

	//this.Update(input);
}
function Initialize(){
	while(this.obj.len() < 5){
		::inputvisualizerDebug.Printf("a");
		local t = ::font.CreateSystemString("a");
		this.obj.append(t);
	}
}

function Update(){
    ::inputvisualizerDebug.Printf("aaaaaaa");
    RecordInputs();
    //PrintInputList();
}

function AddInput(input){
	this.inputs.push(input);
	if (this.inputs.len() > 5){
		this.inputs.pop();
	}
}
function PrintInputList(){
	this.obj = {};
	for (local i = 0; i < this.inputs.len(); i += 1)
	{
		this.obj[i].Set(this.inputs[i]);
	}
	this.obj.ConnectRenderSlot(::graphics.slot.info, 1000);
	::inputvisualizerDebug.Printf("\n");
}

function RecordInputs()
{

	if (::input_all.b0 ==  1){
		PrintInput("B0");
		AddInput("B0");
	}
	if (::input_all.b1 ==  1){
		PrintInput("B1");
		AddInput("B1");
	}
	if (::input_all.b2 ==  1){
		PrintInput("B2");
		AddInput("B2");
	}
	if (::input_all.b3 ==  1){
		PrintInput("B3");
		AddInput("B3");
	}
	if (::input_all.b4 ==  1){
		PrintInput("B4");
		AddInput("B4");
	}
	if (::input_all.b5 ==  1){
		PrintInput("B5");
		AddInput("B5");
	}
}
::inputvisualizerDebug.Printf("aaaaaaa");
::loop.AddTask(this)