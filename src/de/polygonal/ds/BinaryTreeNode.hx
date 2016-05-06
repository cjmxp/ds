﻿/*
Copyright (c) 2008-2016 Michael Baczynski, http://www.polygonal.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
package de.polygonal.ds;

import de.polygonal.ds.tools.ArrayTools;
import de.polygonal.ds.tools.Assert.assert;
import de.polygonal.ds.tools.M;
import de.polygonal.ds.tools.NativeArrayTools;

using de.polygonal.ds.tools.NativeArrayTools;

/**
	A binary tree
	
	A tree data structure in which each node has at most two child nodes.
	
	Example:
		var o = new de.polygonal.ds.BinaryTreeNode<Int>(0);
		o.setL(1);
		o.setR(2);
		o.l.setL(3);
		o.l.l.setR(4);
		trace(o); //outputs:
		
		[ BinaryTree val=0 size=5 depth=0 height=4
		  0
		  L---1
		  |   L---3
		  |   |   R---4
		  R---2
		]
**/
#if generic
@:generic
#end
class BinaryTreeNode<T> implements Collection<T>
{
	/**
		A unique identifier for this object.
		
		A hash table transforms this key into an index of an array element by using a hash function.
		
		<warn>This value should never be changed by the user.</warn>
	**/
	public var key(default, null):Int = HashKey.next();
	
	/**
		The node's data.
	**/
	public var val:T;
	
	/**
		The parent node or null if this node has no parent.
	**/
	public var p:BinaryTreeNode<T>;
	
	/**
		The left child node or null if this node has no left child.
	**/
	public var l:BinaryTreeNode<T>;
	
	/**
		The right child node or null if this node has no right child.
	**/
	public var r:BinaryTreeNode<T>;
	
	var mTimestamp:Int = 0;
	var mStack:NativeArray<BinaryTreeNode<T>> = null;
	
	#if debug
	var mBusy:Bool;
	#end
	
	/**
		Creates a new `BinaryTreeNode` object storing the element `val`.
	**/
	public function new(val:T)
	{
		this.val = val;
		p = l = r = null;
		
		#if debug
		mBusy = false;
		#end
	}
	
	/**
		Performs a recursive _preorder_ traversal.
		
		A preorder traversal performs the following steps:
		
		1. Visit the node
		2. Traverse the left subtree of the node
		3. Traverse the right subtree of the node
		
		@param process a function that is invoked on every traversed node.
		If omitted, `element->visit()` is used instead. <warn>In this case all elements have to implement `Visitable`.</warn>
		The first argument holds a reference to the current node, while the second argument stores custom data specified by the userData parameter (default is null).
		Once `process` returns false, the traversal stops immediately and no further nodes are examined.
		@param iterative if true, an iterative traversal is used (default traversal style is recursive).
		@param userData custom data that is passed to every visited node via `process` or `element->visit()`. If omitted, null is used.
	**/
	public function preorder(process:BinaryTreeNode<T>->Dynamic->Bool = null, iterative:Bool = false, userData:Dynamic = null)
	{
		if (iterative == false)
		{
			if (process == null)
			{
				var v:Dynamic = val;
				var run = v.visit(false, userData);
				if (run && hasL()) run = preorderRecursiveVisitable(l, userData);
				if (run && hasR()) preorderRecursiveVisitable(r, userData);
			}
			else
			{
				var run = process(this, userData);
				if (run && hasL()) run = preorderRecursive(l, process, userData);
				if (run && hasR()) preorderRecursive(r, process, userData);
			}
		}
		else
		{
			var s = getStack();
			var top = 0;
			var max = NativeArrayTools.size(s);
			
			inline function pop() return s.get(--top);
			inline function push(x) s.set(top++, x);
			inline function reserve(n)
				if (n > max)
					s = resizeStack(max <<= 1);
			
			push(this);
			
			if (process == null)
			{
				var node, v:Dynamic;
				while (top != 0)
				{
					node = pop();
					v = node.val;
					if (!v.visit(false, userData)) return;
					
					reserve(top + 2);
					
					if (node.hasR())
						s.set(top++, node.r);
					if (node.hasL())
						s.set(top++, node.l);
				}
			}
			else
			{
				var node;
				while (top != 0)
				{
					node = pop();
					if (!process(node, userData)) return;
					
					reserve(top + 2);
					
					if (node.hasR())
						push(node.r);
					if (node.hasL())
						push(node.l);
				}
			}
		}
	}
	
	/**
		Performs a recursive _inorder_ traversal.
		
		An inorder traversal performs the following steps:
		
		1. Traverse the left subtree of the node
		2. Visit the node
		3. Traverse the right subtree of the node
		
		@param process a function that is invoked on every traversed node.
		If omitted, `element->visit()` is used instead. <warn>In this case all elements have to implement `Visitable`.</warn>
		The first argument holds a reference to the current node, while the second argument stores custom data specified by the userData parameter (default is null).
		Once `process` returns false, the traversal stops immediately and no further nodes are examined.
		@param iterative if true, an iterative traversal is used (default traversal style is recursive).
		@param userData custom data that is passed to every visited node via `process` or `element->visit()`. If omitted, null is used.
	**/
	public function inorder(process:BinaryTreeNode<T>->Dynamic->Bool = null, iterative:Bool = false, userData:Dynamic = null)
	{
		if (iterative == false)
		{
			if (process == null)
			{
				if (hasL())
					if (!inorderRecursiveVisitable(l, userData))
						return;
				
				var v:Dynamic = val;
				if (!v.visit(false, userData)) return;
				if (hasR())
					inorderRecursiveVisitable(r, userData);
			}
			else
			{
				if (hasL())
					if (!inorderRecursive(l, process, userData))
						return;
				if (!process(this, userData)) return;
				if (hasR())
					inorderRecursive(r, process, userData);
			}
		}
		else
		{
			var s = getStack();
			var top = 0;
			var max = NativeArrayTools.size(s);
			
			inline function pop() return s.get(--top);
			inline function push(x) s.set(top++, x);
			inline function reserve(n)
				if (n > max)
					s = resizeStack(max <<= 1);
			
			var node = this;
			
			if (process == null)
			{
				while (node != null)
				{
					while (node != null)
					{
						reserve(top + 2);
						if (node.r != null)
							push(node.r);
						push(node);
						node = node.l;
					}
					
					var v:Dynamic;
					node = pop();
					while (top != 0 && node.r == null)
					{
						v = node.val;
						if (!v.visit(false, userData)) return;
						node = pop();
					}
					
					v = node.val;
					if (!v.visit(false, userData)) return;
					node = (top != 0) ? pop() : null;
				}
			}
			else
			{
				while (node != null)
				{
					while (node != null)
					{
						reserve(top + 2);
						if (node.r != null)
							push(node.r);
						push(node);
						node = node.l;
					}
					
					node = pop();
					while (top != 0 && node.r == null)
					{
						if (!process(node, userData)) return;
						node = pop();
					}
					
					if (!process(node, userData)) return;
					node = (top != 0) ? pop() : null;
				}
			}
		}
	}
	
	/**
		Performs a recursive _postorder_ traversal.
		
		A postorder traversal performs the following steps:
		
		1. Traverse the left subtree of the node
		2. Traverse the right subtree of the node
		3. Visit the node
		
		@param process a function that is invoked on every traversed node.
		If omitted, `element->visit()` is used instead. <warn>In this case all elements have to implement `Visitable`.</warn>
		The first argument holds a reference to the current node, while the second argument stores custom data specified by the userData parameter (default is null).
		Once `process` returns false, the traversal stops immediately and no further nodes are examined.
		@param iterative if true, an iterative traversal is used (default traversal style is recursive).
		@param userData custom data that is passed to every visited node via `process` or `element->visit()`. If omitted, null is used.
	**/
	public function postorder(process:BinaryTreeNode<T>->Dynamic->Bool = null, iterative:Bool = false, userData:Dynamic = null)
	{
		if (iterative == false)
		{
			if (process == null)
			{
				if (hasL())
					if (!postorderRecursiveVisitable(l, userData))
						return;
				if (hasR())
					if (!postorderRecursiveVisitable(r, userData))
						return;
				
				var v:Dynamic = val;
				v.visit(false, userData);
			}
			else
			{
				if (hasL())
					if (!postorderRecursive(l, process, userData))
						return;
				if (hasR())
					if (!postorderRecursive(r, process, userData))
						return;
				process(this, userData);
			}
		}
		else
		{
			#if debug
			assert(mBusy == false, "recursive call to iterative postorder");
			mBusy = true;
			#end
			
			var s = getStack();
			var top = 0;
			var max = NativeArrayTools.size(s);
			
			inline function push(x) s.set(top++, x);
			inline function reserve(n)
				if (n > max)
					s = resizeStack(max <<= 1);
			
			var time = mTimestamp + 1;
			
			push(this);
			
			if (process == null)
			{
				var node, v:Dynamic;
				while (top != 0)
				{
					reserve(top + 1);
					
					node = s.get(top - 1);
					if ((node.l != null) && (node.l.mTimestamp < time))
						push(node.l);
					else
					{
						if ((node.r != null) && (node.r.mTimestamp < time))
							push(node.r);
						else
						{
							v = node.val;
							if (!v.visit(false, userData))
							{
								#if debug
								mBusy = false;
								#end
								return;
							}
							node.mTimestamp++;
							top--;
						}
					}
				}
			}
			else
			{
				var node;
				while (top != 0)
				{
					reserve(top + 1);
					
					node = s.get(top - 1);
					if ((node.l != null) && (node.l.mTimestamp < time))
						push(node.l);
					else
					{
						if ((node.r != null) && (node.r.mTimestamp < time))
							push(node.r);
						else
						{
							if (!process(node, userData))
							{
								#if debug
								mBusy = false;
								#end
								return;
							}
							node.mTimestamp++;
							top--;
						}
					}
				}
			}
			
			#if debug
			mBusy = false;
			#end
		}
	}
	
	/**
		Returns true if this node has a left child node.
	**/
	public inline function hasL():Bool
	{
		return l != null;
	}
	
	/**
		Adds a left child node storing the element `val`.
		
		If a left child exists, only the element is updated to `val`.
	**/
	public inline function setL(val:T)
	{
		if (l == null)
		{
			l = new BinaryTreeNode<T>(val);
			l.p = this;
		}
		else
			l.val = val;
	}
	
	/**
		Returns true if this node has a right child node.
	**/
	public inline function hasR():Bool
	{
		return r != null;
	}
	
	/**
		Adds a right child node storing the element `val`.
		
		If a right child exists, only the element is updated to `val`.
	**/
	public inline function setR(val:T)
	{
		if (r == null)
		{
			r = new BinaryTreeNode<T>(val);
			r.p = this;
		}
		else
			r.val = val;
	}
	
	/**
		Returns true if this node is a left child as seen from its parent node.
	**/
	public inline function isL():Bool
	{
		if (p == null)
			return false;
		else
			return p.l == this;
	}
	
	/**
		Returns true if this node is a right child as seen from its parent node.
	**/
	public inline function isR():Bool
	{
		if (p == null)
			return false;
		else
			return p.r == this;
	}
	
	/**
		Returns true if this node is a leaf node (`l` and `r` are null).
	**/
	public inline function isLeaf():Bool
	{
		return l == null && r == null;
	}
	
	/**
		Returns true if this node is a root node (`p` is null).
	**/
	public inline function isRoot():Bool
	{
		return p == null;
	}
	
	/**
		Calculates the depth of this node.
		
		The depth is defined as the length of the path from the root node to this node.
		
		The root node is at depth 0.
	**/
	public inline function depth():Int
	{
		var node = p;
		var c = 0;
		while (node != null)
		{
			node = node.p;
			c++;
		}
		return c;
	}
	
	/**
		Computes the height of this subtree.
		
		The height is defined as the path from the root node to the deepest node in a tree.
		
		A tree with only a root node has a height of one.
	**/
	public function height():Int
	{
		return 1 + M.max((l != null ? l.height() : 0), r != null ? r.height() : 0);
	}
	
	/**
		Disconnects this node from this subtree.
	**/
	public inline function unlink()
	{
		if (p != null)
		{
			if (isL()) p.l = null;
			else
			if (isR()) p.r = null;
			p = null;
		}
		l = r = null;
	}
	
	/**
		Prints out all elements.
	**/
	public function toString():String
	{
		#if no_tostring
		return Std.string(this);
		#else
		var b = new StringBuf();
		b.add('[ BinaryTree val=${Std.string(val)} size=$size depth=${depth()} height=${height()}');
		if (size == 1)
		{
			b.add(" ]");
			return b.toString();
		}
		b.add("\n");
		var f = function(node:BinaryTreeNode<T>, userData:Dynamic):Bool
		{
			var d = node.depth();
			var t = "";
			for (i in 0...d)
			{
				if (i == d - 1)
					t += (node.isL() ? "L" : "R") + "---";
				else
					t += "|   ";
			}
			
			t = "  " + t;
			b.add(t + node.val + "\n");
			return true;
		}
		preorder(f);
		b.add("]");
		return b.toString();
		#end
	}
	
	function preorderRecursive(node:BinaryTreeNode<T>, process:BinaryTreeNode<T>->Dynamic->Bool, userData:Dynamic):Bool
	{
		var run = process(node, userData);
		if (run && node.hasL()) run = preorderRecursive(node.l, process, userData);
		if (run && node.hasR()) run = preorderRecursive(node.r, process, userData);
		return run;
	}
	
	function preorderRecursiveVisitable(node:BinaryTreeNode<T>, userData:Dynamic):Bool
	{
		var v:Dynamic = node.val;
		var run = v.visit(false, userData);
		if (run && node.hasL()) run = preorderRecursiveVisitable(node.l, userData);
		if (run && node.hasR()) run = preorderRecursiveVisitable(node.r, userData);
		return run;
	}
	
	function inorderRecursive(node:BinaryTreeNode<T>, process:BinaryTreeNode<T>->Dynamic->Bool, userData:Dynamic):Bool
	{
		if (node.hasL())
			if (!inorderRecursive(node.l, process, userData))
				return false;
		if (!process(node, userData)) return false;
		if (node.hasR())
			if (!inorderRecursive(node.r, process, userData))
				return false;
		return true;
	}
	
	function inorderRecursiveVisitable(node:BinaryTreeNode<T>, userData:Dynamic):Bool
	{
		if (node.hasL())
			if (!inorderRecursiveVisitable(node.l, userData))
				return false;
		var v:Dynamic = node.val;
		if (!v.visit(false, userData))
			return false;
		if (node.hasR())
			if (!inorderRecursiveVisitable(node.r, userData))
				return false;
		return true;
	}
	
	function postorderRecursive(node:BinaryTreeNode<T>, process:BinaryTreeNode<T>->Dynamic->Bool, userData:Dynamic):Bool
	{
		if (node.hasL())
			if (!postorderRecursive(node.l, process, userData))
				return false;
		if (node.hasR())
			if (!postorderRecursive(node.r, process, userData))
				return false;
		return process(node, userData);
	}
	
	function postorderRecursiveVisitable(node:BinaryTreeNode<T>, userData:Dynamic):Bool
	{
		if (node.hasL())
			if (!postorderRecursiveVisitable(node.l, userData))
				return false;
		if (node.hasR())
			if (!postorderRecursiveVisitable(node.r, userData))
				return false;
		var v:Dynamic = node.val;
		return v.visit(false, userData);
	}
	
	function heightRecursive(node:BinaryTreeNode<T>):Int
	{
		var cl = -1;
		var cr = -1;
		if (node.hasL())
			cl = heightRecursive(node.l);
		if (node.hasR())
			cr = heightRecursive(node.r);
		return M.max(cl, cr) + 1;
	}
	
	/* INTERFACE Collection */
	
	/**
		Recursively counts the number of nodes in this subtree (including this node).
	**/
	public var size(get, never):Int;
	function get_size():Int
	{
		var c = 1;
		if (hasL()) c += l.size;
		if (hasR()) c += r.size;
		return c;
	}
	
	/**
		Destroys this object by explicitly nullifying all nodes, pointers and elements for GC'ing used resources.
		
		Improves GC efficiency/performance (optional).
	**/
	public function free()
	{
		if (hasL()) l.free();
		if (hasR()) r.free();
		
		val = cast null;
		r = l = p = null;
		mStack = null;
	}
	
	/**
		Returns true if the subtree rooted at this node contains the element `x`.
	**/
	public function contains(val:T):Bool
	{
		var stack = new Array<BinaryTreeNode<T>>();
		stack[0] = this;
		var c = 1;
		var found = false;
		while (c > 0)
		{
			var node = stack[--c];
			if (node.val == val)
			{
				found = true;
				break;
			}
			if (node.hasL()) stack[c++] = node.l;
			if (node.hasR()) stack[c++] = node.r;
		}
		return found;
	}
	
	/**
		Runs a recursive preorder traversal that removes all occurrences of `val`.
		
		Tree nodes are not rearranged, so if a node storing `val` is removed, the subtree rooted at that node is unlinked and lost.
		@return true if at least one occurrence of `val` was removed.
	**/
	public function remove(val:T):Bool
	{
		var found = false;
		if (this.val == val)
		{
			unlink();
			found = true;
		}
		
		if (hasL()) found = found || l.remove(val);
		if (hasR()) found = found || r.remove(val);
		return found;
	}
	
	/**
		Removes all child nodes.
		
		@param gc if true, all nodes and elements of this subtree are recursively nullified so the garbage collector can reclaim used memory.
	**/
	public function clear(gc:Bool = false)
	{
		if (gc)
		{
			if (hasL()) l.clear(gc);
			if (hasR()) r.clear(gc);
			l = r = p = null;
			val = cast null;
		}
		else
			l = r = null;
	}
	
	/**
		Returns a new `BinaryTreeNodeIterator` object to iterate over all elements contained in the nodes of this subtree (including this node).
		
		The elements are visited by using a preorder traversal.
		
		@see http://haxe.org/ref/iterators
	**/
	public function iterator():Itr<T>
	{
		return new BinaryTreeNodeIterator<T>(this);
	}
	
	/**
		<warn>Unsupported operation - always returns false.</warn>
	**/
	public inline function isEmpty():Bool
	{
		return false;
	}
	
	/**
		Returns an array containing all elements in this subtree.
		
		The elements are added by applying a preorder traversal.
	**/
	public function toArray():Array<T>
	{
		if (isEmpty()) return [];
		
		var out = ArrayTools.alloc(size);
		var i = 0;
		preorder(function(node:BinaryTreeNode<T>, userData:Dynamic):Bool { out[i++] = node.val; return true; });
		return out;
	}
	
	/**
		Duplicates this subtree. Supports shallow (structure only) and deep copies (structure & elements).
		@param byRef if true, the `copier` parameter is ignored and primitive elements are copied by value whereas objects are copied by reference.
		If false, the `clone()` method is called on each element. <warn>In this case all elements have to implement `Cloneable`.</warn>
		@param copier a custom function for copying elements. Replaces `element->clone()` if `byRef` is false.
	**/
	public function clone(byRef:Bool = true, copier:T->T = null):Collection<T>
	{
		var stack = new Array<BinaryTreeNode<T>>();
		var copy = new BinaryTreeNode<T>(copier != null ? copier(val) : val);
		stack[0] = this;
		stack[1] = copy;
		var top = 2;
		
		if (byRef)
		{
			while (top > 0)
			{
				var c = stack[--top];
				var n = stack[--top];
				if (n.hasR())
				{
					c.setR(n.r.val);
					stack[top++] = n.r;
					stack[top++] = c.r;
				}
				if (n.hasL())
				{
					c.setL(n.l.val);
					stack[top++] = n.l;
					stack[top++] = c.l;
				}
			}
		}
		else
		if (copier == null)
		{
			while (top > 0)
			{
				var c = stack[--top];
				var n = stack[--top];
				if (n.hasR())
				{
					assert(Std.is(n.r.val, Cloneable), "element is not of type Cloneable");
					
					c.setR(cast(n.r.val, Cloneable<Dynamic>).clone());
					stack[top++] = n.r;
					stack[top++] = c.r;
				}
				if (n.hasL())
				{
					assert(Std.is(n.l.val, Cloneable), "element is not of type Cloneable");
					
					c.setL(cast(n.l.val, Cloneable<Dynamic>).clone());
					stack[top++] = n.l;
					stack[top++] = c.l;
				}
			}
		}
		else
		{
			while (top > 0)
			{
				var c = stack[--top];
				var n = stack[--top];
				if (n.hasR())
				{
					c.setR(copier(n.r.val));
					stack[top++] = n.r;
					stack[top++] = c.r;
				}
				if (n.hasL())
				{
					c.setL(copier(n.l.val));
					stack[top++] = n.l;
					stack[top++] = c.l;
				}
			}
		}
		return copy;
	}
	
	function getStack():NativeArray<BinaryTreeNode<T>>
	{
		if (mStack == null)
		{
			var n = p;
			while (n != null)
			{
				if (n.mStack != null)
				{
					mStack = n.mStack;
					break;
				}
				n = n.p;
			}
			if (mStack == null)
				mStack = NativeArrayTools.alloc(2);
		}
		return mStack;
	}
	
	function resizeStack(newSize:Int):NativeArray<BinaryTreeNode<T>>
	{
		var t = NativeArrayTools.alloc(newSize);
		mStack.blit(0, t, 0, mStack.size());
		return mStack = t;
	}
}

#if generic
@:generic
#end
@:dox(hide)
class BinaryTreeNodeIterator<T> implements de.polygonal.ds.Itr<T>
{
	var mObject:BinaryTreeNode<T>;
	var mStack:Array<BinaryTreeNode<T>>;
	var mTop:Int;
	var mC:Int;
	
	public function new(x:BinaryTreeNode<T>)
	{
		mObject = x;
		mStack = new Array<BinaryTreeNode<T>>();
		reset();
	}
	
	public inline function reset():Itr<T>
	{
		mStack[0] = mObject;
		mTop = 1;
		mC = 0;
		return this;
	}
	
	public inline function hasNext():Bool
	{
		return mTop > 0;
	}
	
	public inline function next():T
	{
		var node = mStack[--mTop];
		mC = 0;
		if (node.hasL())
		{
			mStack[mTop++] = node.l;
			mC++;
		}
		if (node.hasR())
		{
			mStack[mTop++] = node.r;
			mC++;
		}
		return node.val;
	}
	
	public function remove()
	{
		mTop -= mC;
	}
}
