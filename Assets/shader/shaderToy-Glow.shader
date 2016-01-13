/**
 * 文件名： shaderToy 模板着色器，用于模拟shaderToy的环境.
 * 	 
 */

Shader "shadertoy/Glow" 
{ 
    Properties
    {
        iMouse ("Mouse Pos", Vector) = (100,100,0,0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100,100,0,0)
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

		vec4 _Params;
        fixed4 iMouse;
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

        vec4 main(vec2 fragCoord) 
        {
			float pointRadius = 0.06;
			
			float minDimension = min(iResolution.x, iResolution.y);
			vec2 bounds = vec2(iResolution.x / minDimension, iResolution.y / minDimension);
			vec2 uv = fragCoord.xy / minDimension;
			
			vec3 pointB = vec3(0.0, 0.0, 1.0);
			// 将小球，置于中心
			pointB.xy += vec2(bounds.x * 0.5, bounds.y * 0.5);
			
			pointB.x += 0.3*sin(2.24*iGlobalTime);
			pointB.y += 0.3*cos(-1.756*iGlobalTime);
			pointB.z += 0.3*cos(1.245*iGlobalTime);
			
			// 计算，当前点与小球中心的距离
			vec2 vecToB = pointB.xy - uv;
			float distToB = length(vecToB);
			
			// 对颜色进行插值，制造出，中心为纯蓝色；
			// 外围蓝色逐渐递减的 发光小球
			fixed4 fragColor = fixed4(0,0,0,0);
			fragColor.z = smoothstep(0.0, distToB, pointRadius * pointB.z);
			fragColor.w = 1.0;	
			
			return fragColor;
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