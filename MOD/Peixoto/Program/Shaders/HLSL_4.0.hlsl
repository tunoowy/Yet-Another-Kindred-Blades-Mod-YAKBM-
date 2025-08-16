sampler   s {Filter = MIN_MAG_MIP_POINT;};
texture2D t; 
	
struct VxOut {
	float4 pos  : SV_POSITION;
	float2 crds : TEXCOORD0;
};	
	
cbuffer Params : register(b0)
{
	float x0;
	float y0;
	float x1;
	float y1;
	float4 cc;
};		
		
float4 VMirrorBltPx(VxOut input) : SV_TARGET
{
	return t.Sample(s, float2(input.crds.x, 1-input.crds.y));		
}	
		
float4 BltPx(VxOut input) : SV_TARGET
{
	return t.Sample(s, float2(input.crds.x, input.crds.y));		
}
				
VxOut BltVx(uint VertexID: SV_VertexID) 
{
	VxOut OutPut;
								
	float2 v[6] = {x0, y0,  x1, y1,  x0, y1,  x0, y0,  x1, y0,  x1, y1};
	float2 c[6] = {0., 0.,  1., 1.,  0., 1.,  0., 0.,  1., 0.,  1., 1.};
		
	OutPut.pos  = float4(v[VertexID].x, -v[VertexID].y, 0., 1.);		
	OutPut.crds = float2(c[VertexID].x, c[VertexID].y);
	return OutPut;
}   