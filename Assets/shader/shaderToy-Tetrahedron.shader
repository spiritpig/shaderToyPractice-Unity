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
        _OutlineWidth("Outline Width", float) = 1
        _OutlineColor("Outline Color", Color) = (0,0,0,0)
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
        #define sqrt2_divide_4 0.353

        fixed4 iMouse;
        float _CircleRadius, _LineWidth, _OutlineWidth, _Antialias;
        vec4 _BgColor, _LineColor, _CircleColor, _OutlineColor;
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
			float d = length(pos - center) - radius;
			return smoothstep(-antialias, 0, -d);
		}
		
		float lineWeigth(float2 pos, float2 pos1, float2 pos2, float width, float antialias)
		{
			// 求出垂线，计算垂线长度，得出点到直线距离
			vec2 dir = pos2-pos1; // 直线的方向向量
			vec2 v = pos-pos1; // 从直线上一点到线外点的向量
			vec2 c1 = v-dir*(dot(v, dir)/dot(dir, dir));
			float d = length(c1) - width/2.0;
			return smoothstep(-antialias, 0, -d);
		}
		
	    float SegmentWeigth(float2 pos, float2 pos1, float2 pos2, float width, float antialias)
		{
			// 求出垂线，计算垂线长度，得出点到直线距离
			vec2 dir = pos2-pos1; // 直线的方向向量
			vec2 v = pos-pos1; // 从直线上一点到线外点的向量
			vec2 c1 = v - dir * clamp((dot(v, dir)/dot(dir, dir)), 0.0, 1.0);
			float d = length(c1) - width/2.0;
			return smoothstep(-antialias, 0, -d);
		}
		
		float circleDist(float2 pos, float2 center, float radius, float antialias)
		{
			return radius - length(pos - center);
		}
		float SegmentDist(float2 pos, float2 pos1, float2 pos2, float width, float antialias)
		{
			// 求出垂线，计算垂线长度，得出点到直线距离
			vec2 dir = pos2-pos1; // 直线的方向向量
			vec2 v = pos-pos1; // 从直线上一点到线外点的向量
			vec2 c1 = v - dir * clamp((dot(v, dir)/dot(dir, dir)), 0.0, 1.0);
			return width*0.5 - length(c1);
		}

        vec4 main(vec2 fragCoord) 
        {
            vec2 originalPos = (2.0 * fragCoord - iResolution.xy)/iResolution.yy;
        	vec2 pos = originalPos;
        	
        	//Twist 
        	//pos.x += 0.5*sin(5.0*pos.y);
        	
        	vec2 split = vec2(0,0);
        	if(iMouse.z > 0.0)
        	{
        		split = vec2(-iResolution.xy + 2*iMouse.xy) / iResolution.yy;
        	}
        	
      	    // 背景色
		    vec4 col = vec4(_BgColor.rgb * (1.0-0.2*length(originalPos)), .0);
        	vec4 finalColor = col;
        	
        	// 构建旋转矩阵
		    // 参考 http://en.wikipedia.org/wiki/Rotation_matrix
		    float xSpeed = 0.3;
			float ySpeed = 0.5;  
			float zSpeed = 0.7;  
			float3x3 mat = float3x3(1., 0., 0.,  
		                     0., cos(xSpeed*iGlobalTime), sin(xSpeed*iGlobalTime),  
		                     0., -sin(xSpeed*iGlobalTime), cos(xSpeed*iGlobalTime));  
		   	mat = mul(float3x3(cos(ySpeed*iGlobalTime), 0., -sin(ySpeed*iGlobalTime),  
		                     0., 1., 0.,  
		                     sin(ySpeed*iGlobalTime), 0., cos(ySpeed*iGlobalTime)), mat);  
		   	mat = mul(float3x3(cos(zSpeed*iGlobalTime), sin(zSpeed*iGlobalTime), 0.,  
		                      -sin(zSpeed*iGlobalTime), cos(zSpeed*iGlobalTime), 0.,  
		                      0., 0., 0.), mat); 
		                 	 
        	// 四边形
        	float l = 1.0;
        	vec3 p0 = vec3(0., 0.5, sqrt2_divide_4) * l;
    		vec3 p1 = vec3(-0.5, 0, -sqrt2_divide_4) * l;
    		vec3 p2 = vec3(0.5, 0, -sqrt2_divide_4) * l;
    		vec3 p3 = vec3(0, -0.5, sqrt2_divide_4) * l;
    		
    		// 旋转四面体
    		p0 = mul(mat, p0);
    		p1 = mul(mat, p1);
    		p2 = mul(mat, p2);
    		p3 = mul(mat, p3);
    		
        	// 计算颜色
           	float d = SegmentDist(pos, p0.xy, p1.xy, _LineWidth, 0.0);
	       	d = max(SegmentDist(pos, p1.xy, p2.xy, _LineWidth, 0.0), d);
        	d = max(SegmentDist(pos, p2.xy, p0.xy, _LineWidth, 0.0), d);
        	d = max(SegmentDist(pos, p3.xy, p0.xy, _LineWidth, 0.0), d);
        	d = max(SegmentDist(pos, p3.xy, p1.xy, _LineWidth, 0.0), d);
        	d = max(SegmentDist(pos, p3.xy, p2.xy, _LineWidth, 0.0), d);
        	d = max(circleDist(pos, p0.xy, _CircleRadius, 0.0), d);
        	d = max(circleDist(pos, p1.xy, _CircleRadius, 0.0), d);
        	d = max(circleDist(pos, p2.xy, _CircleRadius, 0.0), d);
        	d = max(circleDist(pos, p3.xy, _CircleRadius, 0.0), d);
        	
        	
        	// 颜色混合, 按区域选择抗锯齿方案
        	if(pos.x < split.x)
        	{
        		finalColor = mix(col, _OutlineColor, step(0, d+_OutlineWidth));
        		finalColor = mix(finalColor, _CircleColor, step(0, d));
        	}
        	else if(pos.y > split.y)
        	{
        		finalColor = mix(col, _OutlineColor, smoothstep(-_Antialias, 0, d+_OutlineWidth));
        		finalColor = mix(finalColor, _CircleColor, smoothstep(-_Antialias, 0, d));        	
        	}
        	else
        	{
        		float w = fwidth(0.5*d) * 2.0;
        		finalColor = mix(col, _OutlineColor, smoothstep(-w, 0, d+_OutlineWidth));
        		finalColor = mix(finalColor, _CircleColor, smoothstep(-w, 0, d));   
        	}
        	
        	// 绘制分隔线
        	finalColor = mix(finalColor, vec4(0, 0, 0, 0), smoothstep(-0.01, 0, -abs(split.x - originalPos.x)));
        	finalColor = mix(finalColor, vec4(0, 0, 0, 0), 
        					smoothstep(-0.01, 0, -abs(split.y - originalPos.y)) * step(split.x, originalPos.x) );
        	
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