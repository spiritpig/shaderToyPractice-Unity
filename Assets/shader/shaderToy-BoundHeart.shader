﻿/**
 * 	 画，点和直线该方案从，http://blog.csdn.net/candycat1992/article/details/44244549处，发现。
 */

Shader "shadertoy/template" 
{ 
    Properties
    {
        iMouse ("Mouse Pos", Vector) = (100,100,0,0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100,100,0,0)
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
        #define sqrt2_divide_4 0.353

        fixed4 iMouse;
        vec4 _BgColor;
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
        
        float heartRadius(float theta)
        {
        	return 2. - 2.*sin(theta) + sqrt(abs(cos(theta)))*sin(theta)/(1.4 + sin(theta));
        }
        
        // 7FB2EEFF
        vec4 main(vec2 fragCoord) 
        {
        	vec4 finalColor = vec4(0,0,0,0);
            vec2 originalPos = (2.0 * fragCoord - iResolution.xy)/iResolution.yy;
        	vec2 pos = originalPos;
        	pos.y -= 0.5;        	

			//pos.x /= 0.05*sin(iGlobalTime*5.0) + 0.5;
			//pos.y /= 0.05*cos(iGlobalTime*11.0) + 0.5;
        	//float a = pow(pos.x*pos.x + pos.y*pos.y - 1, 3);      	
        	//float b = pos.x*pos.x*pos.y*pos.y*pos.y;
        	
        	float theta = atan(pos.y, pos.x);
        	float r = heartRadius(theta);
        	
      	    // 背景色
		    vec4 col = vec4(_BgColor.rgb * (1.0-0.3*length(originalPos)), .0);
		    finalColor = col;
        	finalColor = mix(col, vec4(0.5*sin(iGlobalTime*4.0),0.69*cos(iGlobalTime*2.0),0.94,1.0), 
        						smoothstep(0, length(pos), r/8));
        	
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