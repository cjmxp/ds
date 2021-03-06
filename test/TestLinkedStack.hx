﻿import de.polygonal.ds.ArrayedStack;
import de.polygonal.ds.LinkedStack;
import de.polygonal.ds.ListSet;
import de.polygonal.ds.Stack;

@:access(de.polygonal.ds.LinkedStack)
class TestLinkedStack extends AbstractTest
{
	function testSource()
	{
		var l = new LinkedStack<Int>([0, 1, 2, 3]);
		assertEquals(4, l.size);
		for (i in 0...4) assertEquals((4 - i) - 1, l.pop());
	}
	
	function testPool()
	{
		var l = new LinkedStack<Int>(20);
		
		for (i in 0...10) l.push(i);
		for (i in 0...10) l.pop();
		
		assertEquals(10, l.mPoolSize);
		
		for (i in 0...10) l.push(i);
		assertEquals(0, l.mPoolSize);
		
		for (i in 0...10) l.pop();
		assertEquals(10, l.mPoolSize);
	}
	
	function testCpy()
	{
		var l = new LinkedStack<Int>(5);
		for (i in 0...5) l.push(i);
		l.copy(0, 1);
		assertEquals(4, l.get(4));
		assertEquals(3, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(1, l.get(1));
		assertEquals(1, l.get(0));
	}
	
	function testSwp()
	{
		var l = new LinkedStack<Int>(5);
		for (i in 0...5) l.push(i);
		
		l.swap(3, 1);
		
		assertEquals(4, l.get(4));
		assertEquals(1, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(3, l.get(1));
		assertEquals(0, l.get(0));
		
		l.swap(3, 1);
		
		assertEquals(4, l.get(4));
		assertEquals(3, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(1, l.get(1));
		assertEquals(0, l.get(0));
		
		l.swap(1, 3);
		
		assertEquals(4, l.get(4));
		assertEquals(1, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(3, l.get(1));
		assertEquals(0, l.get(0));
		
		l.swap(1, 3);
		
		assertEquals(4, l.get(4));
		assertEquals(3, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(1, l.get(1));
		assertEquals(0, l.get(0));
		
		l.swap(0, 4);
		
		assertEquals(0, l.get(4));
		assertEquals(3, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(1, l.get(1));
		assertEquals(4, l.get(0));
		
		l.swap(0, 4);
		
		assertEquals(4, l.get(4));
		assertEquals(3, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(1, l.get(1));
		assertEquals(0, l.get(0));
		
		l.swap(4, 0);
		
		assertEquals(0, l.get(4));
		assertEquals(3, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(1, l.get(1));
		assertEquals(4, l.get(0));
		
		l.swap(4, 0);
		
		assertEquals(4, l.get(4));
		assertEquals(3, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(1, l.get(1));
		assertEquals(0, l.get(0));
		
		l.swap(0, 1);
		
		assertEquals(4, l.get(4));
		assertEquals(3, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(0, l.get(1));
		assertEquals(1, l.get(0));
		
		l.swap(1, 0);
		
		assertEquals(4, l.get(4));
		assertEquals(3, l.get(3));
		assertEquals(2, l.get(2));
		assertEquals(1, l.get(1));
		assertEquals(0, l.get(0));
	}
	
	function testGetSet()
	{
		var l = new LinkedStack<Int>(20);
		for (i in 0...10) l.push(i);
		for (i in 0...10) assertEquals(i, l.get(i));
		for (i in 0...10) l.set(i, l.get(i) + 10);
		for (i in 0...10) assertEquals(i+10, l.get(i));
	}
	
	function test()
	{
		var l = new LinkedStack<Int>();
		for (i in 0...10)
		{
			l.push(1);
			var x = l.pop();
			assertEquals(1, x);
			
			l.push(1);
			var x = l.pop();
			assertEquals(1, x);
			
			l.push(1);
			l.push(2);
			l.push(3);
			
			var a = l.pop();
			var b = l.pop();
			var c = l.pop();
			
			assertEquals(3, a);
			assertEquals(2, b);
			assertEquals(1, c);
		}
	}
	
	function testDup()
	{
		var s = new LinkedStack<Int>();
		for (i in 0...2) s.push(i);
		s.dup();
		
		assertEquals(3, s.size);
		assertEquals(1, s.top());
		assertEquals(1, s.get(s.size - 2));
		assertEquals(0, s.get(s.size - 3));
	}
	
	function testExchange()
	{
		var s = new LinkedStack<Int>(5);
		s.push(0);
		s.push(1);
		s.exchange();
		assertEquals(0, s.top());
		assertEquals(1, s.get(s.size - 2));
		
		var s = new LinkedStack<Int>(5);
		s.push(0);
		s.push(1);
		s.push(2);
		s.exchange();
		assertEquals(1, s.top());
		assertEquals(2, s.get(s.size - 2));
	}
	
	function testRotRight()
	{
		var s = new LinkedStack<Int>(5);
		s.push(0);
		s.push(1);
		s.push(2);
		s.push(3);
		s.push(4);
		
		s.rotRight(5);
		
		assertEquals(0, s.get(4));
		assertEquals(4, s.get(3));
		assertEquals(3, s.get(2));
		assertEquals(2, s.get(1));
		assertEquals(1, s.get(0));
		
		s.rotRight(5);
		
		assertEquals(1, s.get(4));
		assertEquals(0, s.get(3));
		assertEquals(4, s.get(2));
		assertEquals(3, s.get(1));
		assertEquals(2, s.get(0));
		
		var s = new LinkedStack<Int>(5);
		s.push(0);
		s.push(1);
		s.push(2);
		s.push(3);
		s.push(4);
		
		s.rotRight(3);
		
		assertEquals(2, s.get(4));
		assertEquals(4, s.get(3));
		assertEquals(3, s.get(2));
		assertEquals(1, s.get(1));
		assertEquals(0, s.get(0));
		
		s.rotRight(3);
		
		assertEquals(3, s.get(4));
		assertEquals(2, s.get(3));
		assertEquals(4, s.get(2));
		assertEquals(1, s.get(1));
		assertEquals(0, s.get(0));
		
		s.rotRight(3);
		
		assertEquals(4, s.get(4));
		assertEquals(3, s.get(3));
		assertEquals(2, s.get(2));
		assertEquals(1, s.get(1));
		assertEquals(0, s.get(0));
		
		var s = new LinkedStack<Int>(5);
		s.push(0);
		s.push(1);
		s.push(2);
		s.push(3);
		s.push(4);
		
		s.rotRight(2);
		
		assertEquals(3, s.get(4));
		assertEquals(4, s.get(3));
		assertEquals(2, s.get(2));
		assertEquals(1, s.get(1));
		assertEquals(0, s.get(0));
	}
	
	function testRotLeft()
	{
		var s = new LinkedStack<Int>(5);
		s.push(0);
		s.push(1);
		s.push(2);
		s.push(3);
		s.push(4);
		
		s.rotLeft(5);
		
		assertEquals(3, s.get(4));
		assertEquals(2, s.get(3));
		assertEquals(1, s.get(2));
		assertEquals(0, s.get(1));
		assertEquals(4, s.get(0));
		
		s.rotLeft(5);
		
		assertEquals(2, s.get(4));
		assertEquals(1, s.get(3));
		assertEquals(0, s.get(2));
		assertEquals(4, s.get(1));
		assertEquals(3, s.get(0));
		
		var s = new LinkedStack<Int>(5);
		s.push(0);
		s.push(1);
		s.push(2);
		s.push(3);
		s.push(4);
		
		s.rotLeft(3);
		
		assertEquals(3, s.get(4));
		assertEquals(2, s.get(3));
		assertEquals(4, s.get(2));
		assertEquals(1, s.get(1));
		assertEquals(0, s.get(0));
		
		s.rotLeft(3);
		
		assertEquals(2, s.get(4));
		assertEquals(4, s.get(3));
		assertEquals(3, s.get(2));
		assertEquals(1, s.get(1));
		assertEquals(0, s.get(0));
		
		s.rotLeft(3);
		
		assertEquals(4, s.get(4));
		assertEquals(3, s.get(3));
		assertEquals(2, s.get(2));
		assertEquals(1, s.get(1));
		assertEquals(0, s.get(0));
		
		var s = new LinkedStack<Int>(5);
		s.push(0);
		s.push(1);
		s.push(2);
		s.push(3);
		s.push(4);
		
		s.rotLeft(2);
		
		assertEquals(3, s.get(4));
		assertEquals(4, s.get(3));
		assertEquals(2, s.get(2));
		assertEquals(1, s.get(1));
		assertEquals(0, s.get(0));
	}
	
	function testRemove()
	{
		var l = new LinkedStack<Int>();
		for (i in 0...5) l.push(i);
		
		var k = l.remove(0);
		assertEquals(true, k);
		
		var l = new LinkedStack<Int>();
		for (i in 0...5) l.push(1);
		
		assertTrue(l.remove(1));
		assertTrue(l.isEmpty());
	}
	
	function testFree()
	{
		var l = new LinkedStack<Int>();
		for (i in 0...5) l.push(i);
		l.free();
		assertTrue(true);
	}
	
	function testStack()
	{
		var s:Stack<Int> = new LinkedStack<Int>(5);
		assertTrue(true);
	}
	
	function testToArray()
	{
		var l = new LinkedStack<Int>();
		
		for (i in 0...5) l.push(i);
		
		var a = l.toArray();
		
		for (i in 0...a.length) assertEquals(i, a[i]);
		
		var l = new LinkedStack<Int>();
		for (i in 0...5) l.push(i);
	}
	
	function testClear()
	{
		var l = new LinkedStack<Int>();
		
		for (i in 0...3) l.push(i);
		
		assertEquals(3, l.size);
		
		l.clear();
		
		assertEquals(0, l.size);
		
		for (i in 0...3)
		{
			l.push(i);
			assertEquals(i, l.top());
		}
	}
	
	function testForEach()
	{
		var s = new LinkedStack<Int>();
		s.push(0);
		s.push(1);
		s.push(2);
		
		s.forEach(
			function(v, i)
			{
				assertEquals(i, v);
				return v;
			});
	}
	
	function testIterator()
	{
		var l = new LinkedStack<Int>();
		for (i in 0...5) l.push(i);
		
		var s = new ListSet<Int>();
		for (i in 0...5) s.set(i);
		
		var itr = l.iterator();
		
		var c:de.polygonal.ds.Set<Int> = cast s.clone(true);
		for (i in itr)
		{
			assertEquals(true, c.remove(i));
		}
		assertTrue(c.isEmpty());
		
		l.push(6);
		s.set(6);
		
		var c:de.polygonal.ds.Set<Int> = cast s.clone(true);
		itr.reset();
		for (i in itr)
		{
			assertEquals(true, c.remove(i));
		}
		assertTrue(c.isEmpty());
	}
	
	function testIteratorRemove()
	{
		for (i in 0...5)
		{
			var l = new de.polygonal.ds.LinkedStack<Int>();
			var set = new de.polygonal.ds.ListSet<Int>();
			for (j in 0...5)
			{
				l.push(j);
				if (i != j) set.set(j);
			}
			
			var itr = l.iterator();
			while (itr.hasNext())
			{
				var val = itr.next();
				if (val == i) itr.remove();
			}
			
			while (!l.isEmpty()) assertTrue(set.remove(l.pop()));
			assertTrue(set.isEmpty());
			assertEquals(null, l.mHead);
		}
		
		var l = new de.polygonal.ds.LinkedStack<Int>();
		for (j in 0...5) l.push(j);
		
		var itr = l.iterator();
		while (itr.hasNext())
		{
			itr.next();
			itr.remove();
		}
		assertTrue(l.isEmpty());
		assertEquals(null, l.mHead);
	}
	
	function testClone1()
	{
		var l = new LinkedStack<Int>();
		l.push(1);
		
		var c:LinkedStack<Int> = cast l.clone(true);
		
		#if generic
		var node1:Dynamic = l.mHead;
		var node2:Dynamic = c.mHead;
		#else
		var node1:LinkedStackNode<Int> = l.mHead;
		var node2:LinkedStackNode<Int> = c.mHead;
		#end
		
		while (node1 != null)
		{
			assertEquals(node1.val, node2.val);
			node1 = node1.next;
			node2 = node2.next;
		}
		
		assertEquals(1, c.size);
		var a = c.pop();
		assertEquals(1, a);
	}
	
	function testClone2()
	{
		var l = new LinkedStack<Int>();
		l.push(1);
		l.push(2);
		
		var c:LinkedStack<Int> = cast l.clone(true);
		
		#if generic
		var node1:Dynamic = l.mHead;
		var node2:Dynamic = c.mHead;
		#else
		var node1:LinkedStackNode<Int> = l.mHead;
		var node2:LinkedStackNode<Int> = c.mHead;
		#end
		while (node1 != null)
		{
			assertEquals(node1.val, node2.val);
			node1 = node1.next;
			node2 = node2.next;
		}
		
		assertEquals(2, c.size);
		var a = c.pop();
		var b = c.pop();
		assertEquals(2, a);
		assertEquals(1, b);
	}
	
	function testClone3()
	{
		var l = new LinkedStack<Int>();
		l.push(1);
		l.push(2);
		l.push(3);
		
		var c:LinkedStack<Int> = cast l.clone(true);
		
		#if generic
		var node1:Dynamic = l.mHead;
		var node2:Dynamic = c.mHead;
		#else
		var node1:LinkedStackNode<Int> = l.mHead;
		var node2:LinkedStackNode<Int> = c.mHead;
		#end
		while (node1 != null)
		{
			assertEquals(node1.val, node2.val);
			node1 = node1.next;
			node2 = node2.next;
		}
		
		assertEquals(3, c.size);
		var a = c.pop();
		var b = c.pop();
		var c = c.pop();
		assertEquals(3, a);
		assertEquals(2, b);
		assertEquals(1, c);
	}
}