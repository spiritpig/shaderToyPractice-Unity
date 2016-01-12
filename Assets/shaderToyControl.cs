/**
 * 文件名： shaderToy 模板脚本，用于将鼠标位置传给，着色器
 * 
 */

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using System.Collections;

public class shaderToyControl : MonoBehaviour, IPointerDownHandler, IPointerUpHandler{
	
	private Material _material = null;
	
	private bool _isDragging = false;
	
	// Use this for initialization
	void Start () 
	{
		Image img = GetComponent<Image>();
		if (img != null) 
		{
			_material = img.material;
		}
		
		_isDragging = false;
	}
	
	// Update is called once per frame
	void Update () 
	{
		Vector3 mousePosition = Vector3.zero;
		if (_isDragging) 
		{
			mousePosition = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 1.0f);
		} 
		else 
		{
			mousePosition = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 0.0f);
		}
		
		if (_material != null)
		{
			_material.SetVector("iMouse", mousePosition);
		}
	}
	
	public void OnPointerDown (PointerEventData eventData)
	{
		_isDragging = true;
	}
	
	public void OnPointerUp (PointerEventData eventData)
	{
		_isDragging = false;
	}
}