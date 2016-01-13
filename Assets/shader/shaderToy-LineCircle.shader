/**
 * 	 画，点和直线该方案从，http://blog.csdn.net/candycat1992/article/details/44244549处，发现。
 */

Shader "shadertoy/template" 
{ 
    Properties
    {
        iMouse ("Mouse Pos", Vector) = (100,100,0,0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100,100,0,0)
        _CircleRadius("Circle Radius", float) = 5
        _CircleColor("Circle Color", Color) = (0,0,1,0)
        _LineWidth("Line Width", float) = 2
        _LineColor("Line Color", Color) = (0,1,0,0)
        _Antialias("Antialias Factor", float) = 2
        _BgColor("Background Color", Color) = (0,0,0,0)
    }

    CGINCLUDE    
        #include "UnityCG.cginc"   
        #pragma target 3.0      

        #define vec2 float2
        #define vec3 float3
        #define vec4 float4
        #define mat2 float2x2
        #define iGlobalTime _Time.y
        #define mod fmod
        #define mix lerp
        #define atan atan2
        #define fract frac 
        #define texture2D tex2D
        // 屏幕的尺寸
        #define iResolution _ScreenParams
        // 屏幕中的坐标，以pixel为单位
        #define gl_FragCoord ((_iParam.srcPos.xy/_iParam.srcPos.w)*_ScreenParams.xy) 

        #define PI2 6.28318530718
        #define pi 3.14159265358979
        #define halfpi (pi * 0.5)
        #define oneoverpi (1.0 / pi)

        fixed4 iMouse;
        float _CircleRadius, _LineWidth, _Antialias;
        vec4 _BgColor, _LineColor, _CircleColor;
        sampler2D iChannel0;
        fixed4 iChannelResolution0;

        struct v2f 
        {    
            float4 pos : SV_POSITION;    
            float4 srcPos : TEXCOORD0;   
        };              

        v2f vert(appdata_base v) 
        {  
            v2f o;
            o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
            o.srcPos = ComputeScreenPos(o.pos);  
            return o;    
        }  

        vec4 main(vec2 fragCoord);

        fixed4 frag(v2f _iParam) : COLOR0 
        { 
            vec2 fragCoord = gl_FragCoord;
            return main(gl_FragCoord);
        }  

		vec4 circle(float2 pos, float2 center, float radius)
		{
			float len = length(pos - center);
			if(len < radius)
			{
				return _CircleColor;
			}
			else
			{
				return _BgColor;
			}
		}
		
		float circleWeigth(float2 pos, float2 center, float radius, float antialias)
		{
			float d = length(pos - center);
			return smoothstep(0, d, radius);
		}
		
		float lineWeigth(float2 pos, float2 pos1, float2 pos2, float width, float antialias)
		{
			// 求出垂线，计算垂线长度，得出点到直线距离
			vec2 dir = pos2-pos1; // 直线的方向向量
			vec2 v = pos-pos1; // 从直线上一点到线外点的向量
			vec2 c1 = v-dir*(dot(v, dir)/dot(dir, dir));
			float d = length(c1);
			return smoothstep(0, d, width/2.0);
		}

        vec4 main(vec2 fragCoord) 
        {        	
        	vec2 pos = fragCoord;
        
        	vec4 finalColor;
        	
        	vec2 center1 = vec2(0.3, 0.3), 
        	     center2 = vec2(0.8, 0.7); 
        	float col1 = circleWeigth(pos, center1 * iResolution, _CircleRadius, _Antialias);
        	float col2 = circleWeigth(pos, center2 * iResolution, _CircleRadius, _Antialias);
        	float col3 = lineWeigth(pos, center1 * iResolution, center2 * iResolution, _LineWidth, _Antialias);
        	
        	finalColor = mix(_BgColor, _LineColor, col3);
        	finalColor = mix(finalColor, _CircleColor, col1);
        	finalColor = mix(finalColor, _CircleColor, col2);
        	
            return finalColor;
        }

    ENDCG    

    SubShader 
    {    
        Pass 
        {    
            CGPROGRAM    

            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     

            ENDCG    
        }    
    }
    
    FallBack Off    
}