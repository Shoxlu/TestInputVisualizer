this.env_stack <- [];
this.update_func <- null;
this.task <- {};
this.task_async <- {};
this.pause_count <- 0;
class this.GeneratorTask
{
	gen = null;
	function Set( _gen )
	{
		this.gen = _gen;
		::loop.AddTask(this);
	}

	function Reset()
	{
		this.gen = null;
		::loop.DeleteTask(this);
	}

	function Update()
	{
		if (resume this.gen)
		{
			return;
		}

		::loop.DeleteTask(this);
	}

}

function Begin( env )
{
	if ("Update" in env)
	{
		this.env_stack.append(env);
	}

	this.pause_count = 0;
}

function End( scene = null )
{
	if (scene)
	{
		if (this.env_stack.top() == scene)
		{
			return;
		}

		while (this.env_stack.len() > 0)
		{
			if ("Terminate" in this.env_stack.top())
			{
				this.env_stack.top().Terminate();
			}

			this.env_stack.pop();

			if (this.env_stack.top() == scene)
			{
				break;
			}
		}
	}
	else if (this.env_stack.len() > 0)
	{
		if ("Terminate" in this.env_stack.top())
		{
			this.env_stack.top().Terminate();
		}

		this.env_stack.pop();
	}

	if (this.env_stack.len())
	{
		local env = this.env_stack.top();

		if ("Resume" in env)
		{
			env.Resume.call(env);
		}

		if ("Update" in env)
		{
			this.update_func = env.Update;
		}
	}
	else
	{
		this.update_func = null;
	}
}

function Move( env )
{
	if (this.env_stack.len())
	{
		if ("Terminate" in this.env_stack.top())
		{
			this.env_stack.top().Terminate();
		}

		this.env_stack.pop();
	}

	if ("Update" in env)
	{
		this.env_stack.append(env);
	}

	this.pause_count = 0;
}

function Update()
{
	::input_all.Update();

	if (this.pause_count > 0)
	{
		this.pause_count--;
	}
	else if (::network.IsPlaying())
	{
		if (::network.input_local)
		{
			::network.input_local.Update();
		}

		while (::network.inst && ::network.inst.SyncInput())
		{
			if (this.env_stack.len() > 0)
			{
				this.env_stack.top().Update();
			}

			foreach( v in this.task )
			{
				v.Update();
			}

			if (this.pause_count > 0)
			{
				break;
			}
		}
	}
	else
	{
		if (this.env_stack.len() > 0)
		{
			this.env_stack.top().Update();
		}

		foreach( v in this.task )
		{
			v.Update();
		}

	}

	foreach( v in this.task_async )
	{
		v.Update();
	}
	RecordInputs();
	if(this.is_init){
		PrintInputList();
	}
}

this.text <- null
this.obj <- []
this.inputs <- []
this.is_init <- false

function PrintInput(input){
	local text = ::font.CreateSystemString(input);
	this.text = text;
	this.text.ConnectRenderSlot(::graphics.slot.info, 1000);
	this.text.x = 100.0;
	this.text.y = 500.0;
}

function InitializeInputVisual(){

	for (local i = 0; i < 5; i++){
		::inputvisualizerDebug.Printf("a");
		local t = ::font.CreateSystemString("a");
		this.obj.append(t);
		this.obj[i].ConnectRenderSlot(::graphics.slot.info, 1000);
		this.obj[i].x = 200.0+i*40.0;
		this.obj[i].y = 500.0;
	}
	this.is_init = true;
}

function AddInput(input){
	this.inputs.insert(0, input);
	if (this.inputs.len() > 5){
		this.inputs.pop();
	}
}
function PrintInputList(){
	for (local i = 0; i < this.inputs.len(); i += 1)
	{
		this.obj[i].Set(this.inputs[i]);
		::inputvisualizerDebug.Printf(this.inputs[i]);
	}

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

function Pause( count )
{
	this.pause_count = count;
}

function AddTask( actor, sync = false )
{
	if (sync)
	{
		if (actor.tostring() in this.task_async)
		{
			delete this.task_async[actor.tostring()];
		}

		this.task[actor.tostring()] <- actor;
	}
	else
	{
		if (actor.tostring() in this.task)
		{
			delete this.task[actor.tostring()];
		}

		this.task_async[actor.tostring()] <- actor;
	}
}

function DeleteTask( actor )
{
	if (actor.tostring() in this.task)
	{
		delete this.task[actor.tostring()];
	}
	else if (actor.tostring() in this.task_async)
	{
		delete this.task_async[actor.tostring()];
	}
}

function Fade( callback, count = 30, r = 0, g = 0, b = 0 )
{
	local t = {};
	t.callback <- callback;
	t.count_base <- count;
	t.count <- count;
	t.Update <- function ()
	{
		count = count;

		if (count-- == 0)
		{
			::loop.DeleteTask(this);
			callback();
			::graphics.FadeIn(this.count_base);
			::loop.Pause(3);
		}
	};
	this.Pause(count + 1);
	this.AddTask(t);
	::graphics.FadeOut(count, null, r, g, b);
}

function EndWithFade()
{
	this.Fade(function ()
	{
		::loop.End();
	});
}

function GetCurrentScene()
{
	return this.env_stack.top();
}



::manbow.SetUpdateFunction(function ()
{
	::loop.Update();
});



