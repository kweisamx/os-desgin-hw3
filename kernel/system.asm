
kernel/system:     file format elf32-i386


Disassembly of section .text:

00100000 <_start>:

.globl _start

.text
_start:
	movw	$0x1234,0x472			# warm boot
  100000:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
  100007:	34 12 

	# Setup kernel stack
	movl $0, %ebp
  100009:	bd 00 00 00 00       	mov    $0x0,%ebp
	movl $(bootstacktop), %esp
  10000e:	bc 20 b3 10 00       	mov    $0x10b320,%esp

	call kernel_main
  100013:	e8 04 00 00 00       	call   10001c <kernel_main>

00100018 <die>:
die:
	jmp die
  100018:	eb fe                	jmp    100018 <die>
	...

0010001c <kernel_main>:
#include <kernel/trap.h>
#include <kernel/picirq.h>

extern void init_video(void);
void kernel_main(void)
{
  10001c:	83 ec 0c             	sub    $0xc,%esp
	init_video();
  10001f:	e8 4b 04 00 00       	call   10046f <init_video>

	pic_init();
  100024:	e8 37 00 00 00       	call   100060 <pic_init>
  /* TODO: You should uncomment them
   */
	 kbd_init();
  100029:	e8 00 02 00 00       	call   10022e <kbd_init>
	 //timer_init();
	 trap_init();
  10002e:	e8 70 06 00 00       	call   1006a3 <trap_init>

	/* Enable interrupt */
	__asm __volatile("sti");
  100033:	fb                   	sti    

	shell();
}
  100034:	83 c4 0c             	add    $0xc,%esp
	 trap_init();

	/* Enable interrupt */
	__asm __volatile("sti");

	shell();
  100037:	e9 47 08 00 00       	jmp    100883 <shell>

0010003c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
  10003c:	8b 54 24 04          	mov    0x4(%esp),%edx
	int i;
	irq_mask_8259A = mask;
	if (!didinit)
  100040:	80 3d 20 b3 10 00 00 	cmpb   $0x0,0x10b320
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
  100047:	89 d0                	mov    %edx,%eax
	int i;
	irq_mask_8259A = mask;
  100049:	66 89 15 00 30 10 00 	mov    %dx,0x103000
	if (!didinit)
  100050:	74 0d                	je     10005f <irq_setmask_8259A+0x23>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  100052:	ba 21 00 00 00       	mov    $0x21,%edx
  100057:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
  100058:	66 c1 e8 08          	shr    $0x8,%ax
  10005c:	b2 a1                	mov    $0xa1,%dl
  10005e:	ee                   	out    %al,(%dx)
  10005f:	c3                   	ret    

00100060 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
  100060:	57                   	push   %edi
  100061:	b9 21 00 00 00       	mov    $0x21,%ecx
  100066:	56                   	push   %esi
  100067:	b0 ff                	mov    $0xff,%al
  100069:	53                   	push   %ebx
  10006a:	89 ca                	mov    %ecx,%edx
  10006c:	ee                   	out    %al,(%dx)
  10006d:	be a1 00 00 00       	mov    $0xa1,%esi
  100072:	89 f2                	mov    %esi,%edx
  100074:	ee                   	out    %al,(%dx)
  100075:	bf 11 00 00 00       	mov    $0x11,%edi
  10007a:	bb 20 00 00 00       	mov    $0x20,%ebx
  10007f:	89 f8                	mov    %edi,%eax
  100081:	89 da                	mov    %ebx,%edx
  100083:	ee                   	out    %al,(%dx)
  100084:	b0 20                	mov    $0x20,%al
  100086:	89 ca                	mov    %ecx,%edx
  100088:	ee                   	out    %al,(%dx)
  100089:	b0 04                	mov    $0x4,%al
  10008b:	ee                   	out    %al,(%dx)
  10008c:	b0 03                	mov    $0x3,%al
  10008e:	ee                   	out    %al,(%dx)
  10008f:	b1 a0                	mov    $0xa0,%cl
  100091:	89 f8                	mov    %edi,%eax
  100093:	89 ca                	mov    %ecx,%edx
  100095:	ee                   	out    %al,(%dx)
  100096:	b0 28                	mov    $0x28,%al
  100098:	89 f2                	mov    %esi,%edx
  10009a:	ee                   	out    %al,(%dx)
  10009b:	b0 02                	mov    $0x2,%al
  10009d:	ee                   	out    %al,(%dx)
  10009e:	b0 01                	mov    $0x1,%al
  1000a0:	ee                   	out    %al,(%dx)
  1000a1:	bf 68 00 00 00       	mov    $0x68,%edi
  1000a6:	89 da                	mov    %ebx,%edx
  1000a8:	89 f8                	mov    %edi,%eax
  1000aa:	ee                   	out    %al,(%dx)
  1000ab:	be 0a 00 00 00       	mov    $0xa,%esi
  1000b0:	89 f0                	mov    %esi,%eax
  1000b2:	ee                   	out    %al,(%dx)
  1000b3:	89 f8                	mov    %edi,%eax
  1000b5:	89 ca                	mov    %ecx,%edx
  1000b7:	ee                   	out    %al,(%dx)
  1000b8:	89 f0                	mov    %esi,%eax
  1000ba:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
  1000bb:	66 a1 00 30 10 00    	mov    0x103000,%ax

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
  1000c1:	c6 05 20 b3 10 00 01 	movb   $0x1,0x10b320
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
  1000c8:	66 83 f8 ff          	cmp    $0xffffffff,%ax
  1000cc:	74 0a                	je     1000d8 <pic_init+0x78>
		irq_setmask_8259A(irq_mask_8259A);
  1000ce:	0f b7 c0             	movzwl %ax,%eax
  1000d1:	50                   	push   %eax
  1000d2:	e8 65 ff ff ff       	call   10003c <irq_setmask_8259A>
  1000d7:	58                   	pop    %eax
}
  1000d8:	5b                   	pop    %ebx
  1000d9:	5e                   	pop    %esi
  1000da:	5f                   	pop    %edi
  1000db:	c3                   	ret    

001000dc <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
  1000dc:	53                   	push   %ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1000dd:	ba 64 00 00 00       	mov    $0x64,%edx
  1000e2:	83 ec 08             	sub    $0x8,%esp
  1000e5:	ec                   	in     (%dx),%al
  1000e6:	88 c2                	mov    %al,%dl
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
  1000e8:	83 c8 ff             	or     $0xffffffff,%eax
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
  1000eb:	80 e2 01             	and    $0x1,%dl
  1000ee:	0f 84 d2 00 00 00    	je     1001c6 <kbd_proc_data+0xea>
  1000f4:	ba 60 00 00 00       	mov    $0x60,%edx
  1000f9:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
  1000fa:	3c e0                	cmp    $0xe0,%al
  1000fc:	88 c1                	mov    %al,%cl
  1000fe:	75 09                	jne    100109 <kbd_proc_data+0x2d>
		// E0 escape character
		shift |= E0ESC;
  100100:	83 0d 2c b5 10 00 40 	orl    $0x40,0x10b52c
  100107:	eb 2d                	jmp    100136 <kbd_proc_data+0x5a>
		return 0;
	} else if (data & 0x80) {
  100109:	84 c0                	test   %al,%al
  10010b:	8b 15 2c b5 10 00    	mov    0x10b52c,%edx
  100111:	79 2a                	jns    10013d <kbd_proc_data+0x61>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
  100113:	88 c1                	mov    %al,%cl
  100115:	83 e1 7f             	and    $0x7f,%ecx
  100118:	f6 c2 40             	test   $0x40,%dl
  10011b:	0f 45 c8             	cmovne %eax,%ecx
		shift &= ~(shiftcode[data] | E0ESC);
  10011e:	0f b6 c9             	movzbl %cl,%ecx
  100121:	8a 81 ac 17 10 00    	mov    0x1017ac(%ecx),%al
  100127:	83 c8 40             	or     $0x40,%eax
  10012a:	0f b6 c0             	movzbl %al,%eax
  10012d:	f7 d0                	not    %eax
  10012f:	21 d0                	and    %edx,%eax
  100131:	a3 2c b5 10 00       	mov    %eax,0x10b52c
		return 0;
  100136:	31 c0                	xor    %eax,%eax
  100138:	e9 89 00 00 00       	jmp    1001c6 <kbd_proc_data+0xea>
	} else if (shift & E0ESC) {
  10013d:	f6 c2 40             	test   $0x40,%dl
  100140:	74 0c                	je     10014e <kbd_proc_data+0x72>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
  100142:	83 e2 bf             	and    $0xffffffbf,%edx
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
  100145:	83 c9 80             	or     $0xffffff80,%ecx
		shift &= ~E0ESC;
  100148:	89 15 2c b5 10 00    	mov    %edx,0x10b52c
	}

	shift |= shiftcode[data];
  10014e:	0f b6 c9             	movzbl %cl,%ecx
	shift ^= togglecode[data];
  100151:	0f b6 81 ac 18 10 00 	movzbl 0x1018ac(%ecx),%eax
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
  100158:	0f b6 91 ac 17 10 00 	movzbl 0x1017ac(%ecx),%edx
  10015f:	0b 15 2c b5 10 00    	or     0x10b52c,%edx
	shift ^= togglecode[data];
  100165:	31 c2                	xor    %eax,%edx

	c = charcode[shift & (CTL | SHIFT)][data];
  100167:	89 d0                	mov    %edx,%eax
  100169:	83 e0 03             	and    $0x3,%eax
	if (shift & CAPSLOCK) {
  10016c:	f6 c2 08             	test   $0x8,%dl
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];

	c = charcode[shift & (CTL | SHIFT)][data];
  10016f:	8b 04 85 ac 19 10 00 	mov    0x1019ac(,%eax,4),%eax
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];
  100176:	89 15 2c b5 10 00    	mov    %edx,0x10b52c

	c = charcode[shift & (CTL | SHIFT)][data];
  10017c:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
	if (shift & CAPSLOCK) {
  100180:	74 19                	je     10019b <kbd_proc_data+0xbf>
		if ('a' <= c && c <= 'z')
  100182:	8d 48 9f             	lea    -0x61(%eax),%ecx
  100185:	83 f9 19             	cmp    $0x19,%ecx
  100188:	77 05                	ja     10018f <kbd_proc_data+0xb3>
			c += 'A' - 'a';
  10018a:	83 e8 20             	sub    $0x20,%eax
  10018d:	eb 0c                	jmp    10019b <kbd_proc_data+0xbf>
		else if ('A' <= c && c <= 'Z')
  10018f:	8d 58 bf             	lea    -0x41(%eax),%ebx
			c += 'a' - 'A';
  100192:	8d 48 20             	lea    0x20(%eax),%ecx
  100195:	83 fb 19             	cmp    $0x19,%ebx
  100198:	0f 46 c1             	cmovbe %ecx,%eax
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10019b:	3d e9 00 00 00       	cmp    $0xe9,%eax
  1001a0:	75 24                	jne    1001c6 <kbd_proc_data+0xea>
  1001a2:	f7 d2                	not    %edx
  1001a4:	80 e2 06             	and    $0x6,%dl
  1001a7:	75 1d                	jne    1001c6 <kbd_proc_data+0xea>
		cprintf("Rebooting!\n");
  1001a9:	83 ec 0c             	sub    $0xc,%esp
  1001ac:	68 a0 17 10 00       	push   $0x1017a0
  1001b1:	e8 a0 05 00 00       	call   100756 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  1001b6:	ba 92 00 00 00       	mov    $0x92,%edx
  1001bb:	b0 03                	mov    $0x3,%al
  1001bd:	ee                   	out    %al,(%dx)
  1001be:	b8 e9 00 00 00       	mov    $0xe9,%eax
  1001c3:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
  1001c6:	83 c4 08             	add    $0x8,%esp
  1001c9:	5b                   	pop    %ebx
  1001ca:	c3                   	ret    

001001cb <cons_getc>:
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	//kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  1001cb:	8b 15 24 b5 10 00    	mov    0x10b524,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
  1001d1:	31 c0                	xor    %eax,%eax
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	//kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  1001d3:	3b 15 28 b5 10 00    	cmp    0x10b528,%edx
  1001d9:	74 1b                	je     1001f6 <cons_getc+0x2b>
		c = cons.buf[cons.rpos++];
  1001db:	8d 4a 01             	lea    0x1(%edx),%ecx
  1001de:	0f b6 82 24 b3 10 00 	movzbl 0x10b324(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
  1001e5:	31 d2                	xor    %edx,%edx
  1001e7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  1001ed:	0f 45 d1             	cmovne %ecx,%edx
  1001f0:	89 15 24 b5 10 00    	mov    %edx,0x10b524
		return c;
	}
	return 0;
}
  1001f6:	c3                   	ret    

001001f7 <kbd_intr>:
/* 
 *  Note: The interrupt handler
 */
void
kbd_intr(void)
{
  1001f7:	53                   	push   %ebx
	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
  1001f8:	31 db                	xor    %ebx,%ebx
/* 
 *  Note: The interrupt handler
 */
void
kbd_intr(void)
{
  1001fa:	83 ec 08             	sub    $0x8,%esp
  1001fd:	eb 20                	jmp    10021f <kbd_intr+0x28>
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
  1001ff:	85 c0                	test   %eax,%eax
  100201:	74 1c                	je     10021f <kbd_intr+0x28>
			continue;
		cons.buf[cons.wpos++] = c;
  100203:	8b 15 28 b5 10 00    	mov    0x10b528,%edx
  100209:	88 82 24 b3 10 00    	mov    %al,0x10b324(%edx)
  10020f:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
  100212:	3d 00 02 00 00       	cmp    $0x200,%eax
  100217:	0f 44 c3             	cmove  %ebx,%eax
  10021a:	a3 28 b5 10 00       	mov    %eax,0x10b528
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
  10021f:	e8 b8 fe ff ff       	call   1000dc <kbd_proc_data>
  100224:	83 f8 ff             	cmp    $0xffffffff,%eax
  100227:	75 d6                	jne    1001ff <kbd_intr+0x8>
 */
void
kbd_intr(void)
{
	cons_intr(kbd_proc_data);
}
  100229:	83 c4 08             	add    $0x8,%esp
  10022c:	5b                   	pop    %ebx
  10022d:	c3                   	ret    

0010022e <kbd_init>:

void kbd_init(void)
{
  10022e:	83 ec 0c             	sub    $0xc,%esp
	// Drain the kbd buffer so that Bochs generates interrupts.
  cons.rpos = 0;
  100231:	c7 05 24 b5 10 00 00 	movl   $0x0,0x10b524
  100238:	00 00 00 
  cons.wpos = 0;
  10023b:	c7 05 28 b5 10 00 00 	movl   $0x0,0x10b528
  100242:	00 00 00 
	kbd_intr();
  100245:	e8 ad ff ff ff       	call   1001f7 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
  10024a:	0f b7 05 00 30 10 00 	movzwl 0x103000,%eax
  100251:	83 ec 0c             	sub    $0xc,%esp
  100254:	25 fd ff 00 00       	and    $0xfffd,%eax
  100259:	50                   	push   %eax
  10025a:	e8 dd fd ff ff       	call   10003c <irq_setmask_8259A>
}
  10025f:	83 c4 1c             	add    $0x1c,%esp
  100262:	c3                   	ret    

00100263 <getc>:
/* high-level console I/O */
int getc(void)
{
	int c;

	while ((c = cons_getc()) == 0)
  100263:	e8 63 ff ff ff       	call   1001cb <cons_getc>
  100268:	85 c0                	test   %eax,%eax
  10026a:	74 f7                	je     100263 <getc>
		/* do nothing */;
	return c;
}
  10026c:	c3                   	ret    
  10026d:	00 00                	add    %al,(%eax)
	...

00100270 <scroll>:
int attrib = 0x0F;
int csr_x = 0, csr_y = 0;

/* Scrolls the screen */
void scroll(void)
{
  100270:	56                   	push   %esi
  100271:	53                   	push   %ebx
  100272:	83 ec 04             	sub    $0x4,%esp
    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);

    /* Row 25 is the end, this means we need to scroll up */
    if(csr_y >= 25)
  100275:	8b 1d 34 b5 10 00    	mov    0x10b534,%ebx
{
    unsigned short blank, temp;

    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);
  10027b:	8b 35 04 33 10 00    	mov    0x103304,%esi

    /* Row 25 is the end, this means we need to scroll up */
    if(csr_y >= 25)
  100281:	83 fb 18             	cmp    $0x18,%ebx
  100284:	7e 58                	jle    1002de <scroll+0x6e>
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
  100286:	83 eb 18             	sub    $0x18,%ebx
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
  100289:	a1 40 b9 10 00       	mov    0x10b940,%eax
  10028e:	0f b7 db             	movzwl %bx,%ebx
  100291:	52                   	push   %edx
  100292:	69 d3 60 ff ff ff    	imul   $0xffffff60,%ebx,%edx
{
    unsigned short blank, temp;

    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);
  100298:	c1 e6 08             	shl    $0x8,%esi
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
  10029b:	0f b7 f6             	movzwl %si,%esi
    if(csr_y >= 25)
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
  10029e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
  1002a4:	52                   	push   %edx
  1002a5:	69 d3 a0 00 00 00    	imul   $0xa0,%ebx,%edx

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
  1002ab:	6b db b0             	imul   $0xffffffb0,%ebx,%ebx
    if(csr_y >= 25)
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
  1002ae:	8d 14 10             	lea    (%eax,%edx,1),%edx
  1002b1:	52                   	push   %edx
  1002b2:	50                   	push   %eax
  1002b3:	e8 f1 10 00 00       	call   1013a9 <memcpy>

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
  1002b8:	83 c4 0c             	add    $0xc,%esp
  1002bb:	8d 84 1b a0 0f 00 00 	lea    0xfa0(%ebx,%ebx,1),%eax
  1002c2:	03 05 40 b9 10 00    	add    0x10b940,%eax
  1002c8:	6a 50                	push   $0x50
  1002ca:	56                   	push   %esi
  1002cb:	50                   	push   %eax
  1002cc:	e8 fe 0f 00 00       	call   1012cf <memset>
        csr_y = 25 - 1;
  1002d1:	83 c4 10             	add    $0x10,%esp
  1002d4:	c7 05 34 b5 10 00 18 	movl   $0x18,0x10b534
  1002db:	00 00 00 
    }
}
  1002de:	83 c4 04             	add    $0x4,%esp
  1002e1:	5b                   	pop    %ebx
  1002e2:	5e                   	pop    %esi
  1002e3:	c3                   	ret    

001002e4 <move_csr>:
    unsigned short temp;

    /* The equation for finding the index in a linear
    *  chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    temp = csr_y * 80 + csr_x;
  1002e4:	66 6b 0d 34 b5 10 00 	imul   $0x50,0x10b534,%cx
  1002eb:	50 
  1002ec:	ba d4 03 00 00       	mov    $0x3d4,%edx
  1002f1:	03 0d 30 b5 10 00    	add    0x10b530,%ecx
  1002f7:	b0 0e                	mov    $0xe,%al
  1002f9:	ee                   	out    %al,(%dx)
    *  where the hardware cursor is to be 'blinking'. To
    *  learn more, you should look up some VGA specific
    *  programming documents. A great start to graphics:
    *  http://www.brackeen.com/home/vga */
    outb(0x3D4, 14);
    outb(0x3D5, temp >> 8);
  1002fa:	89 c8                	mov    %ecx,%eax
  1002fc:	b2 d5                	mov    $0xd5,%dl
  1002fe:	66 c1 e8 08          	shr    $0x8,%ax
  100302:	ee                   	out    %al,(%dx)
  100303:	b0 0f                	mov    $0xf,%al
  100305:	b2 d4                	mov    $0xd4,%dl
  100307:	ee                   	out    %al,(%dx)
  100308:	b2 d5                	mov    $0xd5,%dl
  10030a:	88 c8                	mov    %cl,%al
  10030c:	ee                   	out    %al,(%dx)
    outb(0x3D4, 15);
    outb(0x3D5, temp);
}
  10030d:	c3                   	ret    

0010030e <cls>:

/* Clears the screen */
void cls()
{
  10030e:	56                   	push   %esi
  10030f:	53                   	push   %ebx
    unsigned short blank;
    int i;

    /* Again, we need the 'short' that will be used to
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);
  100310:	31 db                	xor    %ebx,%ebx
    outb(0x3D5, temp);
}

/* Clears the screen */
void cls()
{
  100312:	83 ec 04             	sub    $0x4,%esp
    unsigned short blank;
    int i;

    /* Again, we need the 'short' that will be used to
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);
  100315:	8b 35 04 33 10 00    	mov    0x103304,%esi
  10031b:	c1 e6 08             	shl    $0x8,%esi

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < 25; i++)
        memset (textmemptr + i * 80, blank, 80);
  10031e:	0f b7 f6             	movzwl %si,%esi
  100321:	a1 40 b9 10 00       	mov    0x10b940,%eax
  100326:	51                   	push   %ecx
  100327:	6a 50                	push   $0x50
  100329:	56                   	push   %esi
  10032a:	01 d8                	add    %ebx,%eax
  10032c:	81 c3 a0 00 00 00    	add    $0xa0,%ebx
  100332:	50                   	push   %eax
  100333:	e8 97 0f 00 00       	call   1012cf <memset>
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < 25; i++)
  100338:	83 c4 10             	add    $0x10,%esp
  10033b:	81 fb a0 0f 00 00    	cmp    $0xfa0,%ebx
  100341:	75 de                	jne    100321 <cls+0x13>
        memset (textmemptr + i * 80, blank, 80);

    /* Update out virtual cursor, and then move the
    *  hardware cursor */
    csr_x = 0;
  100343:	c7 05 30 b5 10 00 00 	movl   $0x0,0x10b530
  10034a:	00 00 00 
    csr_y = 0;
  10034d:	c7 05 34 b5 10 00 00 	movl   $0x0,0x10b534
  100354:	00 00 00 
    move_csr();
}
  100357:	83 c4 04             	add    $0x4,%esp
  10035a:	5b                   	pop    %ebx
  10035b:	5e                   	pop    %esi

    /* Update out virtual cursor, and then move the
    *  hardware cursor */
    csr_x = 0;
    csr_y = 0;
    move_csr();
  10035c:	e9 83 ff ff ff       	jmp    1002e4 <move_csr>

00100361 <putch>:
}

/* Puts a single character on the screen */
void putch(unsigned char c)
{
  100361:	53                   	push   %ebx
  100362:	83 ec 08             	sub    $0x8,%esp
    unsigned short *where;
    unsigned short att = attrib << 8;
  100365:	8b 0d 04 33 10 00    	mov    0x103304,%ecx
    move_csr();
}

/* Puts a single character on the screen */
void putch(unsigned char c)
{
  10036b:	8a 44 24 10          	mov    0x10(%esp),%al
    unsigned short *where;
    unsigned short att = attrib << 8;
  10036f:	c1 e1 08             	shl    $0x8,%ecx

    /* Handle a backspace, by moving the cursor back one space */
    if(c == 0x08)
  100372:	3c 08                	cmp    $0x8,%al
  100374:	75 21                	jne    100397 <putch+0x36>
    {
        if(csr_x != 0) {
  100376:	a1 30 b5 10 00       	mov    0x10b530,%eax
  10037b:	85 c0                	test   %eax,%eax
  10037d:	74 7d                	je     1003fc <putch+0x9b>
          where = (textmemptr-1) + (csr_y * 80 + csr_x);
  10037f:	6b 15 34 b5 10 00 50 	imul   $0x50,0x10b534,%edx
  100386:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
          *where = 0x0 | att;	/* Character AND attributes: color */
  10038a:	8b 15 40 b9 10 00    	mov    0x10b940,%edx
          csr_x--;
  100390:	48                   	dec    %eax
    /* Handle a backspace, by moving the cursor back one space */
    if(c == 0x08)
    {
        if(csr_x != 0) {
          where = (textmemptr-1) + (csr_y * 80 + csr_x);
          *where = 0x0 | att;	/* Character AND attributes: color */
  100391:	66 89 0c 5a          	mov    %cx,(%edx,%ebx,2)
  100395:	eb 0f                	jmp    1003a6 <putch+0x45>
          csr_x--;
        }
    }
    /* Handles a tab by incrementing the cursor's x, but only
    *  to a point that will make it divisible by 8 */
    else if(c == 0x09)
  100397:	3c 09                	cmp    $0x9,%al
  100399:	75 12                	jne    1003ad <putch+0x4c>
    {
        csr_x = (csr_x + 8) & ~(8 - 1);
  10039b:	a1 30 b5 10 00       	mov    0x10b530,%eax
  1003a0:	83 c0 08             	add    $0x8,%eax
  1003a3:	83 e0 f8             	and    $0xfffffff8,%eax
  1003a6:	a3 30 b5 10 00       	mov    %eax,0x10b530
  1003ab:	eb 4f                	jmp    1003fc <putch+0x9b>
    }
    /* Handles a 'Carriage Return', which simply brings the
    *  cursor back to the margin */
    else if(c == '\r')
  1003ad:	3c 0d                	cmp    $0xd,%al
  1003af:	75 0c                	jne    1003bd <putch+0x5c>
    {
        csr_x = 0;
  1003b1:	c7 05 30 b5 10 00 00 	movl   $0x0,0x10b530
  1003b8:	00 00 00 
  1003bb:	eb 3f                	jmp    1003fc <putch+0x9b>
    }
    /* We handle our newlines the way DOS and the BIOS do: we
    *  treat it as if a 'CR' was also there, so we bring the
    *  cursor to the margin and we increment the 'y' value */
    else if(c == '\n')
  1003bd:	3c 0a                	cmp    $0xa,%al
  1003bf:	75 12                	jne    1003d3 <putch+0x72>
    {
        csr_x = 0;
  1003c1:	c7 05 30 b5 10 00 00 	movl   $0x0,0x10b530
  1003c8:	00 00 00 
        csr_y++;
  1003cb:	ff 05 34 b5 10 00    	incl   0x10b534
  1003d1:	eb 29                	jmp    1003fc <putch+0x9b>
    }
    /* Any character greater than and including a space, is a
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
  1003d3:	3c 1f                	cmp    $0x1f,%al
  1003d5:	76 25                	jbe    1003fc <putch+0x9b>
    {
        where = textmemptr + (csr_y * 80 + csr_x);
  1003d7:	8b 15 30 b5 10 00    	mov    0x10b530,%edx
        *where = c | att;	/* Character AND attributes: color */
  1003dd:	0f b6 c0             	movzbl %al,%eax
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
  1003e0:	6b 1d 34 b5 10 00 50 	imul   $0x50,0x10b534,%ebx
        *where = c | att;	/* Character AND attributes: color */
  1003e7:	09 c8                	or     %ecx,%eax
  1003e9:	8b 0d 40 b9 10 00    	mov    0x10b940,%ecx
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
  1003ef:	01 d3                	add    %edx,%ebx
        *where = c | att;	/* Character AND attributes: color */
        csr_x++;
  1003f1:	42                   	inc    %edx
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
        *where = c | att;	/* Character AND attributes: color */
  1003f2:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
        csr_x++;
  1003f6:	89 15 30 b5 10 00    	mov    %edx,0x10b530
    }

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
  1003fc:	83 3d 30 b5 10 00 4f 	cmpl   $0x4f,0x10b530
  100403:	7e 10                	jle    100415 <putch+0xb4>
    {
        csr_x = 0;
        csr_y++;
  100405:	ff 05 34 b5 10 00    	incl   0x10b534

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
    {
        csr_x = 0;
  10040b:	c7 05 30 b5 10 00 00 	movl   $0x0,0x10b530
  100412:	00 00 00 
        csr_y++;
    }

    /* Scroll the screen if needed, and finally move the cursor */
    scroll();
  100415:	e8 56 fe ff ff       	call   100270 <scroll>
    move_csr();
}
  10041a:	83 c4 08             	add    $0x8,%esp
  10041d:	5b                   	pop    %ebx
        csr_y++;
    }

    /* Scroll the screen if needed, and finally move the cursor */
    scroll();
    move_csr();
  10041e:	e9 c1 fe ff ff       	jmp    1002e4 <move_csr>

00100423 <puts>:
}

/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
  100423:	56                   	push   %esi
  100424:	53                   	push   %ebx
    int i;

    for (i = 0; i < strlen(text); i++)
  100425:	31 db                	xor    %ebx,%ebx
    move_csr();
}

/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
  100427:	83 ec 04             	sub    $0x4,%esp
  10042a:	8b 74 24 10          	mov    0x10(%esp),%esi
    int i;

    for (i = 0; i < strlen(text); i++)
  10042e:	eb 11                	jmp    100441 <puts+0x1e>
    {
        putch(text[i]);
  100430:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
  100434:	83 ec 0c             	sub    $0xc,%esp
/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
    int i;

    for (i = 0; i < strlen(text); i++)
  100437:	43                   	inc    %ebx
    {
        putch(text[i]);
  100438:	50                   	push   %eax
  100439:	e8 23 ff ff ff       	call   100361 <putch>
/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
    int i;

    for (i = 0; i < strlen(text); i++)
  10043e:	83 c4 10             	add    $0x10,%esp
  100441:	83 ec 0c             	sub    $0xc,%esp
  100444:	56                   	push   %esi
  100445:	e8 b6 0c 00 00       	call   101100 <strlen>
  10044a:	83 c4 10             	add    $0x10,%esp
  10044d:	39 c3                	cmp    %eax,%ebx
  10044f:	7c df                	jl     100430 <puts+0xd>
    {
        putch(text[i]);
    }
}
  100451:	83 c4 04             	add    $0x4,%esp
  100454:	5b                   	pop    %ebx
  100455:	5e                   	pop    %esi
  100456:	c3                   	ret    

00100457 <settextcolor>:
void settextcolor(unsigned char forecolor, unsigned char backcolor)
{
    /* Lab3: Use this function */
    /* Top 4 bit are the background, bottom 4 bytes
    *  are the foreground color */
    attrib = (backcolor << 4) | (forecolor & 0x0F);
  100457:	0f b6 44 24 08       	movzbl 0x8(%esp),%eax
  10045c:	0f b6 54 24 04       	movzbl 0x4(%esp),%edx
  100461:	c1 e0 04             	shl    $0x4,%eax
  100464:	83 e2 0f             	and    $0xf,%edx
  100467:	09 d0                	or     %edx,%eax
  100469:	a3 04 33 10 00       	mov    %eax,0x103304
}
  10046e:	c3                   	ret    

0010046f <init_video>:

/* Sets our text-mode VGA pointer, then clears the screen for us */
void init_video(void)
{
  10046f:	83 ec 0c             	sub    $0xc,%esp
    textmemptr = (unsigned short *)0xB8000;
  100472:	c7 05 40 b9 10 00 00 	movl   $0xb8000,0x10b940
  100479:	80 0b 00 
    cls();
}
  10047c:	83 c4 0c             	add    $0xc,%esp

/* Sets our text-mode VGA pointer, then clears the screen for us */
void init_video(void)
{
    textmemptr = (unsigned short *)0xB8000;
    cls();
  10047f:	e9 8a fe ff ff       	jmp    10030e <cls>

00100484 <print_regs>:
}

/* For debugging */
void
print_regs(struct PushRegs *regs)
{
  100484:	53                   	push   %ebx
  100485:	83 ec 10             	sub    $0x10,%esp
  100488:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
  10048c:	ff 33                	pushl  (%ebx)
  10048e:	68 bc 19 10 00       	push   $0x1019bc
  100493:	e8 be 02 00 00       	call   100756 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
  100498:	58                   	pop    %eax
  100499:	5a                   	pop    %edx
  10049a:	ff 73 04             	pushl  0x4(%ebx)
  10049d:	68 cb 19 10 00       	push   $0x1019cb
  1004a2:	e8 af 02 00 00       	call   100756 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  1004a7:	5a                   	pop    %edx
  1004a8:	59                   	pop    %ecx
  1004a9:	ff 73 08             	pushl  0x8(%ebx)
  1004ac:	68 da 19 10 00       	push   $0x1019da
  1004b1:	e8 a0 02 00 00       	call   100756 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  1004b6:	59                   	pop    %ecx
  1004b7:	58                   	pop    %eax
  1004b8:	ff 73 0c             	pushl  0xc(%ebx)
  1004bb:	68 e9 19 10 00       	push   $0x1019e9
  1004c0:	e8 91 02 00 00       	call   100756 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  1004c5:	58                   	pop    %eax
  1004c6:	5a                   	pop    %edx
  1004c7:	ff 73 10             	pushl  0x10(%ebx)
  1004ca:	68 f8 19 10 00       	push   $0x1019f8
  1004cf:	e8 82 02 00 00       	call   100756 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
  1004d4:	5a                   	pop    %edx
  1004d5:	59                   	pop    %ecx
  1004d6:	ff 73 14             	pushl  0x14(%ebx)
  1004d9:	68 07 1a 10 00       	push   $0x101a07
  1004de:	e8 73 02 00 00       	call   100756 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  1004e3:	59                   	pop    %ecx
  1004e4:	58                   	pop    %eax
  1004e5:	ff 73 18             	pushl  0x18(%ebx)
  1004e8:	68 16 1a 10 00       	push   $0x101a16
  1004ed:	e8 64 02 00 00       	call   100756 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
  1004f2:	58                   	pop    %eax
  1004f3:	5a                   	pop    %edx
  1004f4:	ff 73 1c             	pushl  0x1c(%ebx)
  1004f7:	68 25 1a 10 00       	push   $0x101a25
  1004fc:	e8 55 02 00 00       	call   100756 <cprintf>
}
  100501:	83 c4 18             	add    $0x18,%esp
  100504:	5b                   	pop    %ebx
  100505:	c3                   	ret    

00100506 <print_trapframe>:
}

/* For debugging */
void
print_trapframe(struct Trapframe *tf)
{
  100506:	56                   	push   %esi
  100507:	53                   	push   %ebx
  100508:	83 ec 10             	sub    $0x10,%esp
  10050b:	8b 5c 24 1c          	mov    0x1c(%esp),%ebx
	cprintf("TRAP frame at %p \n");
  10050f:	68 89 1a 10 00       	push   $0x101a89
  100514:	e8 3d 02 00 00       	call   100756 <cprintf>
	print_regs(&tf->tf_regs);
  100519:	89 1c 24             	mov    %ebx,(%esp)
  10051c:	e8 63 ff ff ff       	call   100484 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
  100521:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
  100525:	5a                   	pop    %edx
  100526:	59                   	pop    %ecx
  100527:	50                   	push   %eax
  100528:	68 9c 1a 10 00       	push   $0x101a9c
  10052d:	e8 24 02 00 00       	call   100756 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
  100532:	5e                   	pop    %esi
  100533:	58                   	pop    %eax
  100534:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
  100538:	50                   	push   %eax
  100539:	68 af 1a 10 00       	push   $0x101aaf
  10053e:	e8 13 02 00 00       	call   100756 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  100543:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
  100546:	83 c4 10             	add    $0x10,%esp
  100549:	83 f8 13             	cmp    $0x13,%eax
  10054c:	77 09                	ja     100557 <print_trapframe+0x51>
		return excnames[trapno];
  10054e:	8b 14 85 98 1c 10 00 	mov    0x101c98(,%eax,4),%edx
  100555:	eb 1d                	jmp    100574 <print_trapframe+0x6e>
	if (trapno == T_SYSCALL)
  100557:	83 f8 30             	cmp    $0x30,%eax
		return "System call";
  10055a:	ba 34 1a 10 00       	mov    $0x101a34,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
  10055f:	74 13                	je     100574 <print_trapframe+0x6e>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
  100561:	8d 48 e0             	lea    -0x20(%eax),%ecx
		return "Hardware Interrupt";
  100564:	ba 40 1a 10 00       	mov    $0x101a40,%edx
  100569:	83 f9 0f             	cmp    $0xf,%ecx
  10056c:	b9 53 1a 10 00       	mov    $0x101a53,%ecx
  100571:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p \n");
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  100574:	51                   	push   %ecx
  100575:	52                   	push   %edx
  100576:	50                   	push   %eax
  100577:	68 c2 1a 10 00       	push   $0x101ac2
  10057c:	e8 d5 01 00 00       	call   100756 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  100581:	83 c4 10             	add    $0x10,%esp
  100584:	3b 1d 38 b5 10 00    	cmp    0x10b538,%ebx
  10058a:	75 19                	jne    1005a5 <print_trapframe+0x9f>
  10058c:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
  100590:	75 13                	jne    1005a5 <print_trapframe+0x9f>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
  100592:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
  100595:	52                   	push   %edx
  100596:	52                   	push   %edx
  100597:	50                   	push   %eax
  100598:	68 d4 1a 10 00       	push   $0x101ad4
  10059d:	e8 b4 01 00 00       	call   100756 <cprintf>
  1005a2:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
  1005a5:	56                   	push   %esi
  1005a6:	56                   	push   %esi
  1005a7:	ff 73 2c             	pushl  0x2c(%ebx)
  1005aa:	68 e3 1a 10 00       	push   $0x101ae3
  1005af:	e8 a2 01 00 00       	call   100756 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
  1005b4:	83 c4 10             	add    $0x10,%esp
  1005b7:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
  1005bb:	75 43                	jne    100600 <print_trapframe+0xfa>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
  1005bd:	8b 73 2c             	mov    0x2c(%ebx),%esi
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
  1005c0:	b8 6d 1a 10 00       	mov    $0x101a6d,%eax
  1005c5:	b9 62 1a 10 00       	mov    $0x101a62,%ecx
  1005ca:	ba 79 1a 10 00       	mov    $0x101a79,%edx
  1005cf:	f7 c6 01 00 00 00    	test   $0x1,%esi
  1005d5:	0f 44 c8             	cmove  %eax,%ecx
  1005d8:	f7 c6 02 00 00 00    	test   $0x2,%esi
  1005de:	b8 7f 1a 10 00       	mov    $0x101a7f,%eax
  1005e3:	0f 44 d0             	cmove  %eax,%edx
  1005e6:	83 e6 04             	and    $0x4,%esi
  1005e9:	51                   	push   %ecx
  1005ea:	b8 84 1a 10 00       	mov    $0x101a84,%eax
  1005ef:	be b2 1d 10 00       	mov    $0x101db2,%esi
  1005f4:	52                   	push   %edx
  1005f5:	0f 44 c6             	cmove  %esi,%eax
  1005f8:	50                   	push   %eax
  1005f9:	68 f1 1a 10 00       	push   $0x101af1
  1005fe:	eb 08                	jmp    100608 <print_trapframe+0x102>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
  100600:	83 ec 0c             	sub    $0xc,%esp
  100603:	68 9a 1a 10 00       	push   $0x101a9a
  100608:	e8 49 01 00 00       	call   100756 <cprintf>
  10060d:	5a                   	pop    %edx
  10060e:	59                   	pop    %ecx
	cprintf("  eip  0x%08x\n", tf->tf_eip);
  10060f:	ff 73 30             	pushl  0x30(%ebx)
  100612:	68 00 1b 10 00       	push   $0x101b00
  100617:	e8 3a 01 00 00       	call   100756 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
  10061c:	5e                   	pop    %esi
  10061d:	58                   	pop    %eax
  10061e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
  100622:	50                   	push   %eax
  100623:	68 0f 1b 10 00       	push   $0x101b0f
  100628:	e8 29 01 00 00       	call   100756 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
  10062d:	5a                   	pop    %edx
  10062e:	59                   	pop    %ecx
  10062f:	ff 73 38             	pushl  0x38(%ebx)
  100632:	68 22 1b 10 00       	push   $0x101b22
  100637:	e8 1a 01 00 00       	call   100756 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
  10063c:	83 c4 10             	add    $0x10,%esp
  10063f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
  100643:	74 23                	je     100668 <print_trapframe+0x162>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
  100645:	50                   	push   %eax
  100646:	50                   	push   %eax
  100647:	ff 73 3c             	pushl  0x3c(%ebx)
  10064a:	68 31 1b 10 00       	push   $0x101b31
  10064f:	e8 02 01 00 00       	call   100756 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
  100654:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
  100658:	59                   	pop    %ecx
  100659:	5e                   	pop    %esi
  10065a:	50                   	push   %eax
  10065b:	68 40 1b 10 00       	push   $0x101b40
  100660:	e8 f1 00 00 00       	call   100756 <cprintf>
  100665:	83 c4 10             	add    $0x10,%esp
	}
}
  100668:	83 c4 04             	add    $0x4,%esp
  10066b:	5b                   	pop    %ebx
  10066c:	5e                   	pop    %esi
  10066d:	c3                   	ret    

0010066e <default_trap_handler>:

/* 
 * Note: This is the called for every interrupt.
 */
void default_trap_handler(struct Trapframe *tf)
{
  10066e:	83 ec 0c             	sub    $0xc,%esp
  100671:	8b 44 24 10          	mov    0x10(%esp),%eax
}

static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
  100675:	8b 50 28             	mov    0x28(%eax),%edx
 */
void default_trap_handler(struct Trapframe *tf)
{
	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
  100678:	a3 38 b5 10 00       	mov    %eax,0x10b538
}

static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
  10067d:	83 fa 21             	cmp    $0x21,%edx
  100680:	75 08                	jne    10068a <default_trap_handler+0x1c>
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
  100682:	83 c4 0c             	add    $0xc,%esp
static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
    {
        kbd_intr();
  100685:	e9 6d fb ff ff       	jmp    1001f7 <kbd_intr>
        return;
    }
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
  10068a:	83 fa 20             	cmp    $0x20,%edx
  10068d:	75 08                	jne    100697 <default_trap_handler+0x29>
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
  10068f:	83 c4 0c             	add    $0xc,%esp
        kbd_intr();
        return;
    }
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
    {
        timer_handler();
  100692:	e9 1b 03 00 00       	jmp    1009b2 <timer_handler>
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
  100697:	89 44 24 10          	mov    %eax,0x10(%esp)
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
  10069b:	83 c4 0c             	add    $0xc,%esp
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
  10069e:	e9 63 fe ff ff       	jmp    100506 <print_trapframe>

001006a3 <trap_init>:
{
 //   int i;                                                                       
   // for(i = 0;i < 256; i++)
     //   SETGATE(idt[i],0,GD_KT,64*i,0);
           
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,kbd,0);
  1006a3:	b8 0a 07 10 00       	mov    $0x10070a,%eax
  1006a8:	66 a3 4c ba 10 00    	mov    %ax,0x10ba4c
  1006ae:	c1 e8 10             	shr    $0x10,%eax
  1006b1:	66 a3 52 ba 10 00    	mov    %ax,0x10ba52
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,timer,0);
  1006b7:	b8 04 07 10 00       	mov    $0x100704,%eax
  1006bc:	66 a3 44 ba 10 00    	mov    %ax,0x10ba44
  1006c2:	c1 e8 10             	shr    $0x10,%eax
  1006c5:	66 a3 4a ba 10 00    	mov    %ax,0x10ba4a
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
  1006cb:	b8 08 33 10 00       	mov    $0x103308,%eax
{
 //   int i;                                                                       
   // for(i = 0;i < 256; i++)
     //   SETGATE(idt[i],0,GD_KT,64*i,0);
           
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,kbd,0);
  1006d0:	66 c7 05 4e ba 10 00 	movw   $0x8,0x10ba4e
  1006d7:	08 00 
  1006d9:	c6 05 50 ba 10 00 00 	movb   $0x0,0x10ba50
  1006e0:	c6 05 51 ba 10 00 8e 	movb   $0x8e,0x10ba51
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,timer,0);
  1006e7:	66 c7 05 46 ba 10 00 	movw   $0x8,0x10ba46
  1006ee:	08 00 
  1006f0:	c6 05 48 ba 10 00 00 	movb   $0x0,0x10ba48
  1006f7:	c6 05 49 ba 10 00 8e 	movb   $0x8e,0x10ba49
  1006fe:	0f 01 18             	lidtl  (%eax)

	/* Keyboard interrupt setup */
	/* Timer Trap setup */
  /* Load IDT */

}
  100701:	c3                   	ret    
	...

00100704 <timer>:
	pushl $(num);							\
	jmp _alltraps


.text
    TRAPHANDLER_NOEC(timer,IRQ_OFFSET + IRQ_TIMER)
  100704:	6a 00                	push   $0x0
  100706:	6a 20                	push   $0x20
  100708:	eb 06                	jmp    100710 <_alltraps>

0010070a <kbd>:
    TRAPHANDLER_NOEC(kbd,IRQ_OFFSET + IRQ_KBD)   
  10070a:	6a 00                	push   $0x0
  10070c:	6a 21                	push   $0x21
  10070e:	eb 00                	jmp    100710 <_alltraps>

00100710 <_alltraps>:
   *       CPU.
   *       You may want to leverage the "pusha" instructions to reduce your work of
   *       pushing all the general purpose registers into the stack.
	 */
/*because  in kernel stack ,we need to reverse the push order trapno ->     ds - > es -> pusha*/
    pushl %ds
  100710:	1e                   	push   %ds
    pushl %es
  100711:	06                   	push   %es
    pusha          #  push AX CX BX SP BP SI DI
  100712:	60                   	pusha  

    /*load kernel segment */
    movw $(GD_KT), %ax
  100713:	66 b8 08 00          	mov    $0x8,%ax
    movw %ax , %ds
  100717:	8e d8                	mov    %eax,%ds
    movw %ax , %es
  100719:	8e c0                	mov    %eax,%es

	pushl %esp # Pass a pointer which points to the Trapframe as an argument to default_trap_handler()
  10071b:	54                   	push   %esp
	call default_trap_handler
  10071c:	e8 4d ff ff ff       	call   10066e <default_trap_handler>
    popl %esp
  100721:	5c                   	pop    %esp
    popa
  100722:	61                   	popa   
    popl %es
  100723:	07                   	pop    %es
    popl %ds
  100724:	1f                   	pop    %ds

	add $8, %esp # Cleans up the pushed error code and pushed ISR number
  100725:	83 c4 08             	add    $0x8,%esp
	iret # pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP!
  100728:	cf                   	iret   
  100729:	00 00                	add    %al,(%eax)
	...

0010072c <vcprintf>:
#include <inc/stdio.h>


int
vcprintf(const char *fmt, va_list ap)
{
  10072c:	83 ec 1c             	sub    $0x1c,%esp
	int cnt = 0;
  10072f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  100736:	00 

	vprintfmt((void*)putch, &cnt, fmt, ap);
  100737:	ff 74 24 24          	pushl  0x24(%esp)
  10073b:	ff 74 24 24          	pushl  0x24(%esp)
  10073f:	8d 44 24 14          	lea    0x14(%esp),%eax
  100743:	50                   	push   %eax
  100744:	68 61 03 10 00       	push   $0x100361
  100749:	e8 11 04 00 00       	call   100b5f <vprintfmt>
	return cnt;
}
  10074e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  100752:	83 c4 2c             	add    $0x2c,%esp
  100755:	c3                   	ret    

00100756 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  100756:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  100759:	8d 44 24 14          	lea    0x14(%esp),%eax
	cnt = vcprintf(fmt, ap);
  10075d:	52                   	push   %edx
  10075e:	52                   	push   %edx
  10075f:	50                   	push   %eax
  100760:	ff 74 24 1c          	pushl  0x1c(%esp)
  100764:	e8 c3 ff ff ff       	call   10072c <vcprintf>
	va_end(ap);

	return cnt;
}
  100769:	83 c4 1c             	add    $0x1c,%esp
  10076c:	c3                   	ret    
  10076d:	00 00                	add    %al,(%eax)
	...

00100770 <mon_kerninfo>:
    extern int kernel_load_addr;
    //extern int __STAB_BEGIN__;
    //extern int __STAB_END__;
    //extern int __STABSTR_BEGIN__;
    //extern int __STABSTR_END__;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,&etext-&kernel_load_addr);
  100770:	b8 95 17 10 00       	mov    $0x101795,%eax
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int mon_kerninfo(int argc, char **argv)
{
  100775:	83 ec 10             	sub    $0x10,%esp
    extern int kernel_load_addr;
    //extern int __STAB_BEGIN__;
    //extern int __STAB_END__;
    //extern int __STABSTR_BEGIN__;
    //extern int __STABSTR_END__;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,&etext-&kernel_load_addr);
  100778:	2d 00 00 10 00       	sub    $0x100000,%eax
  10077d:	c1 f8 02             	sar    $0x2,%eax
  100780:	50                   	push   %eax
  100781:	68 00 00 10 00       	push   $0x100000
  100786:	68 e8 1c 10 00       	push   $0x101ce8
  10078b:	e8 c6 ff ff ff       	call   100756 <cprintf>
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,&end-&data_start);
  100790:	b8 44 c1 10 00       	mov    $0x10c144,%eax
  100795:	83 c4 0c             	add    $0xc,%esp
  100798:	2d 00 30 10 00       	sub    $0x103000,%eax
  10079d:	c1 f8 02             	sar    $0x2,%eax
  1007a0:	50                   	push   %eax
  1007a1:	68 00 30 10 00       	push   $0x103000
  1007a6:	68 12 1d 10 00       	push   $0x101d12
  1007ab:	e8 a6 ff ff ff       	call   100756 <cprintf>
    cprintf("Kernel executable memory footprint: %10xKB\n");
  1007b0:	c7 04 24 3c 1d 10 00 	movl   $0x101d3c,(%esp)
  1007b7:	e8 9a ff ff ff       	call   100756 <cprintf>
	return 0;
}
  1007bc:	31 c0                	xor    %eax,%eax
  1007be:	83 c4 1c             	add    $0x1c,%esp
  1007c1:	c3                   	ret    

001007c2 <mon_help>:
}
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))


int mon_help(int argc, char **argv)
{
  1007c2:	83 ec 10             	sub    $0x10,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  1007c5:	68 68 1d 10 00       	push   $0x101d68
  1007ca:	68 86 1d 10 00       	push   $0x101d86
  1007cf:	68 8b 1d 10 00       	push   $0x101d8b
  1007d4:	e8 7d ff ff ff       	call   100756 <cprintf>
  1007d9:	83 c4 0c             	add    $0xc,%esp
  1007dc:	68 94 1d 10 00       	push   $0x101d94
  1007e1:	68 b9 1d 10 00       	push   $0x101db9
  1007e6:	68 8b 1d 10 00       	push   $0x101d8b
  1007eb:	e8 66 ff ff ff       	call   100756 <cprintf>
  1007f0:	83 c4 0c             	add    $0xc,%esp
  1007f3:	68 c2 1d 10 00       	push   $0x101dc2
  1007f8:	68 d6 1d 10 00       	push   $0x101dd6
  1007fd:	68 8b 1d 10 00       	push   $0x101d8b
  100802:	e8 4f ff ff ff       	call   100756 <cprintf>
  100807:	83 c4 0c             	add    $0xc,%esp
  10080a:	68 e1 1d 10 00       	push   $0x101de1
  10080f:	68 f6 1d 10 00       	push   $0x101df6
  100814:	68 8b 1d 10 00       	push   $0x101d8b
  100819:	e8 38 ff ff ff       	call   100756 <cprintf>
	return 0;
}
  10081e:	31 c0                	xor    %eax,%eax
  100820:	83 c4 1c             	add    $0x1c,%esp
  100823:	c3                   	ret    

00100824 <print_tick>:
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,&end-&data_start);
    cprintf("Kernel executable memory footprint: %10xKB\n");
	return 0;
}
int print_tick(int argc, char **argv)
{
  100824:	83 ec 0c             	sub    $0xc,%esp
	cprintf("Now tick = %d\n", get_tick());
  100827:	e8 8d 01 00 00       	call   1009b9 <get_tick>
  10082c:	c7 44 24 10 ff 1d 10 	movl   $0x101dff,0x10(%esp)
  100833:	00 
  100834:	89 44 24 14          	mov    %eax,0x14(%esp)
}
  100838:	83 c4 0c             	add    $0xc,%esp
    cprintf("Kernel executable memory footprint: %10xKB\n");
	return 0;
}
int print_tick(int argc, char **argv)
{
	cprintf("Now tick = %d\n", get_tick());
  10083b:	e9 16 ff ff ff       	jmp    100756 <cprintf>

00100840 <chgcolor>:
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
  100840:	53                   	push   %ebx
  100841:	83 ec 08             	sub    $0x8,%esp
    if(argc == 1)
  100844:	83 7c 24 10 01       	cmpl   $0x1,0x10(%esp)
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
  100849:	8b 5c 24 14          	mov    0x14(%esp),%ebx
    if(argc == 1)
  10084d:	75 0a                	jne    100859 <chgcolor+0x19>
        cprintf("NO input text colors!\n");
  10084f:	83 ec 0c             	sub    $0xc,%esp
  100852:	68 0e 1e 10 00       	push   $0x101e0e
  100857:	eb 1e                	jmp    100877 <chgcolor+0x37>
    else{
        settextcolor((unsigned char)(*argv[1]),0);
  100859:	51                   	push   %ecx
  10085a:	51                   	push   %ecx
  10085b:	6a 00                	push   $0x0
  10085d:	8b 43 04             	mov    0x4(%ebx),%eax
  100860:	0f b6 00             	movzbl (%eax),%eax
  100863:	50                   	push   %eax
  100864:	e8 ee fb ff ff       	call   100457 <settextcolor>
        cprintf("Change color %c!\n",*argv[1]);
  100869:	58                   	pop    %eax
  10086a:	8b 43 04             	mov    0x4(%ebx),%eax
  10086d:	5a                   	pop    %edx
  10086e:	0f be 00             	movsbl (%eax),%eax
  100871:	50                   	push   %eax
  100872:	68 25 1e 10 00       	push   $0x101e25
  100877:	e8 da fe ff ff       	call   100756 <cprintf>
    }   
    return 0;
                            
}
  10087c:	31 c0                	xor    %eax,%eax
  10087e:	83 c4 18             	add    $0x18,%esp
  100881:	5b                   	pop    %ebx
  100882:	c3                   	ret    

00100883 <shell>:
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}
void shell()
{
  100883:	55                   	push   %ebp
  100884:	57                   	push   %edi
  100885:	56                   	push   %esi
  100886:	53                   	push   %ebx
  100887:	83 ec 58             	sub    $0x58,%esp
	char *buf;
	cprintf("Welcome to the OSDI course!\n");
  10088a:	68 37 1e 10 00       	push   $0x101e37
  10088f:	e8 c2 fe ff ff       	call   100756 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
  100894:	c7 04 24 54 1e 10 00 	movl   $0x101e54,(%esp)
  10089b:	e8 b6 fe ff ff       	call   100756 <cprintf>
  1008a0:	83 c4 10             	add    $0x10,%esp
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
  1008a3:	89 e5                	mov    %esp,%ebp
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
  1008a5:	83 ec 0c             	sub    $0xc,%esp
  1008a8:	68 79 1e 10 00       	push   $0x101e79
  1008ad:	e8 9e 07 00 00       	call   101050 <readline>
		if (buf != NULL)
  1008b2:	83 c4 10             	add    $0x10,%esp
  1008b5:	85 c0                	test   %eax,%eax
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
  1008b7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
  1008b9:	74 ea                	je     1008a5 <shell+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
  1008bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
  1008c2:	31 f6                	xor    %esi,%esi
  1008c4:	eb 04                	jmp    1008ca <shell+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
  1008c6:	c6 03 00             	movb   $0x0,(%ebx)
  1008c9:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
  1008ca:	8a 03                	mov    (%ebx),%al
  1008cc:	84 c0                	test   %al,%al
  1008ce:	74 17                	je     1008e7 <shell+0x64>
  1008d0:	57                   	push   %edi
  1008d1:	0f be c0             	movsbl %al,%eax
  1008d4:	57                   	push   %edi
  1008d5:	50                   	push   %eax
  1008d6:	68 80 1e 10 00       	push   $0x101e80
  1008db:	e8 91 09 00 00       	call   101271 <strchr>
  1008e0:	83 c4 10             	add    $0x10,%esp
  1008e3:	85 c0                	test   %eax,%eax
  1008e5:	75 df                	jne    1008c6 <shell+0x43>
			*buf++ = 0;
		if (*buf == 0)
  1008e7:	80 3b 00             	cmpb   $0x0,(%ebx)
  1008ea:	74 36                	je     100922 <shell+0x9f>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
  1008ec:	83 fe 0f             	cmp    $0xf,%esi
  1008ef:	75 0b                	jne    1008fc <shell+0x79>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
  1008f1:	51                   	push   %ecx
  1008f2:	51                   	push   %ecx
  1008f3:	6a 10                	push   $0x10
  1008f5:	68 85 1e 10 00       	push   $0x101e85
  1008fa:	eb 7d                	jmp    100979 <shell+0xf6>
			return 0;
		}
		argv[argc++] = buf;
  1008fc:	89 1c b4             	mov    %ebx,(%esp,%esi,4)
  1008ff:	46                   	inc    %esi
  100900:	eb 01                	jmp    100903 <shell+0x80>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
  100902:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
  100903:	8a 03                	mov    (%ebx),%al
  100905:	84 c0                	test   %al,%al
  100907:	74 c1                	je     1008ca <shell+0x47>
  100909:	52                   	push   %edx
  10090a:	0f be c0             	movsbl %al,%eax
  10090d:	52                   	push   %edx
  10090e:	50                   	push   %eax
  10090f:	68 80 1e 10 00       	push   $0x101e80
  100914:	e8 58 09 00 00       	call   101271 <strchr>
  100919:	83 c4 10             	add    $0x10,%esp
  10091c:	85 c0                	test   %eax,%eax
  10091e:	74 e2                	je     100902 <shell+0x7f>
  100920:	eb a8                	jmp    1008ca <shell+0x47>
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
  100922:	85 f6                	test   %esi,%esi
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
  100924:	c7 04 b4 00 00 00 00 	movl   $0x0,(%esp,%esi,4)

	// Lookup and invoke the command
	if (argc == 0)
  10092b:	0f 84 74 ff ff ff    	je     1008a5 <shell+0x22>
  100931:	bf b8 1e 10 00       	mov    $0x101eb8,%edi
  100936:	31 db                	xor    %ebx,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
  100938:	50                   	push   %eax
  100939:	50                   	push   %eax
  10093a:	ff 37                	pushl  (%edi)
  10093c:	83 c7 0c             	add    $0xc,%edi
  10093f:	ff 74 24 0c          	pushl  0xc(%esp)
  100943:	e8 b2 08 00 00       	call   1011fa <strcmp>
  100948:	83 c4 10             	add    $0x10,%esp
  10094b:	85 c0                	test   %eax,%eax
  10094d:	75 19                	jne    100968 <shell+0xe5>
			return commands[i].func(argc, argv);
  10094f:	6b db 0c             	imul   $0xc,%ebx,%ebx
  100952:	57                   	push   %edi
  100953:	57                   	push   %edi
  100954:	55                   	push   %ebp
  100955:	56                   	push   %esi
  100956:	ff 93 c0 1e 10 00    	call   *0x101ec0(%ebx)
	while(1)
	{
		buf = readline("OSDI> ");
		if (buf != NULL)
		{
			if (runcmd(buf) < 0)
  10095c:	83 c4 10             	add    $0x10,%esp
  10095f:	85 c0                	test   %eax,%eax
  100961:	78 23                	js     100986 <shell+0x103>
  100963:	e9 3d ff ff ff       	jmp    1008a5 <shell+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
  100968:	43                   	inc    %ebx
  100969:	83 fb 04             	cmp    $0x4,%ebx
  10096c:	75 ca                	jne    100938 <shell+0xb5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
  10096e:	53                   	push   %ebx
  10096f:	53                   	push   %ebx
  100970:	ff 74 24 08          	pushl  0x8(%esp)
  100974:	68 a2 1e 10 00       	push   $0x101ea2
  100979:	e8 d8 fd ff ff       	call   100756 <cprintf>
  10097e:	83 c4 10             	add    $0x10,%esp
  100981:	e9 1f ff ff ff       	jmp    1008a5 <shell+0x22>
		{
			if (runcmd(buf) < 0)
				break;
		}
	}
}
  100986:	83 c4 4c             	add    $0x4c,%esp
  100989:	5b                   	pop    %ebx
  10098a:	5e                   	pop    %esi
  10098b:	5f                   	pop    %edi
  10098c:	5d                   	pop    %ebp
  10098d:	c3                   	ret    
	...

00100990 <set_timer>:

static unsigned long jiffies = 0;

void set_timer(int hz)
{
    int divisor = 1193180 / hz;       /* Calculate our divisor */
  100990:	b9 dc 34 12 00       	mov    $0x1234dc,%ecx
  100995:	89 c8                	mov    %ecx,%eax
  100997:	99                   	cltd   
  100998:	f7 7c 24 04          	idivl  0x4(%esp)
  10099c:	ba 43 00 00 00       	mov    $0x43,%edx
  1009a1:	89 c1                	mov    %eax,%ecx
  1009a3:	b0 36                	mov    $0x36,%al
  1009a5:	ee                   	out    %al,(%dx)
  1009a6:	b2 40                	mov    $0x40,%dl
  1009a8:	88 c8                	mov    %cl,%al
  1009aa:	ee                   	out    %al,(%dx)
    outb(0x43, 0x36);             /* Set our command byte 0x36 */
    outb(0x40, divisor & 0xFF);   /* Set low byte of divisor */
    outb(0x40, divisor >> 8);     /* Set high byte of divisor */
  1009ab:	89 c8                	mov    %ecx,%eax
  1009ad:	c1 f8 08             	sar    $0x8,%eax
  1009b0:	ee                   	out    %al,(%dx)
}
  1009b1:	c3                   	ret    

001009b2 <timer_handler>:
/* 
 * Timer interrupt handler
 */
void timer_handler()
{
	jiffies++;
  1009b2:	ff 05 3c b5 10 00    	incl   0x10b53c
}
  1009b8:	c3                   	ret    

001009b9 <get_tick>:

unsigned long get_tick()
{
	return jiffies;
}
  1009b9:	a1 3c b5 10 00       	mov    0x10b53c,%eax
  1009be:	c3                   	ret    

001009bf <timer_init>:
void timer_init()
{
  1009bf:	83 ec 0c             	sub    $0xc,%esp
	set_timer(TIME_HZ);
  1009c2:	6a 64                	push   $0x64
  1009c4:	e8 c7 ff ff ff       	call   100990 <set_timer>

	/* Enable interrupt */
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_TIMER));
  1009c9:	50                   	push   %eax
  1009ca:	50                   	push   %eax
  1009cb:	0f b7 05 00 30 10 00 	movzwl 0x103000,%eax
  1009d2:	25 fe ff 00 00       	and    $0xfffe,%eax
  1009d7:	50                   	push   %eax
  1009d8:	e8 5f f6 ff ff       	call   10003c <irq_setmask_8259A>
}
  1009dd:	83 c4 1c             	add    $0x1c,%esp
  1009e0:	c3                   	ret    
	...

001009f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  1009f0:	55                   	push   %ebp
  1009f1:	57                   	push   %edi
  1009f2:	56                   	push   %esi
  1009f3:	53                   	push   %ebx
  1009f4:	83 ec 3c             	sub    $0x3c,%esp
  1009f7:	89 c5                	mov    %eax,%ebp
  1009f9:	89 d6                	mov    %edx,%esi
  1009fb:	8b 44 24 50          	mov    0x50(%esp),%eax
  1009ff:	89 44 24 24          	mov    %eax,0x24(%esp)
  100a03:	8b 54 24 54          	mov    0x54(%esp),%edx
  100a07:	89 54 24 20          	mov    %edx,0x20(%esp)
  100a0b:	8b 5c 24 5c          	mov    0x5c(%esp),%ebx
  100a0f:	8b 7c 24 60          	mov    0x60(%esp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  100a13:	b8 00 00 00 00       	mov    $0x0,%eax
  100a18:	39 d0                	cmp    %edx,%eax
  100a1a:	72 13                	jb     100a2f <printnum+0x3f>
  100a1c:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  100a20:	39 4c 24 58          	cmp    %ecx,0x58(%esp)
  100a24:	76 09                	jbe    100a2f <printnum+0x3f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  100a26:	83 eb 01             	sub    $0x1,%ebx
  100a29:	85 db                	test   %ebx,%ebx
  100a2b:	7f 63                	jg     100a90 <printnum+0xa0>
  100a2d:	eb 71                	jmp    100aa0 <printnum+0xb0>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  100a2f:	89 7c 24 10          	mov    %edi,0x10(%esp)
  100a33:	83 eb 01             	sub    $0x1,%ebx
  100a36:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  100a3a:	8b 5c 24 58          	mov    0x58(%esp),%ebx
  100a3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  100a42:	8b 44 24 08          	mov    0x8(%esp),%eax
  100a46:	8b 54 24 0c          	mov    0xc(%esp),%edx
  100a4a:	89 44 24 28          	mov    %eax,0x28(%esp)
  100a4e:	89 54 24 2c          	mov    %edx,0x2c(%esp)
  100a52:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  100a59:	00 
  100a5a:	8b 54 24 24          	mov    0x24(%esp),%edx
  100a5e:	89 14 24             	mov    %edx,(%esp)
  100a61:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  100a65:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100a69:	e8 d2 0a 00 00       	call   101540 <__udivdi3>
  100a6e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  100a72:	8b 5c 24 2c          	mov    0x2c(%esp),%ebx
  100a76:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100a7a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  100a7e:	89 04 24             	mov    %eax,(%esp)
  100a81:	89 54 24 04          	mov    %edx,0x4(%esp)
  100a85:	89 f2                	mov    %esi,%edx
  100a87:	89 e8                	mov    %ebp,%eax
  100a89:	e8 62 ff ff ff       	call   1009f0 <printnum>
  100a8e:	eb 10                	jmp    100aa0 <printnum+0xb0>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  100a90:	89 74 24 04          	mov    %esi,0x4(%esp)
  100a94:	89 3c 24             	mov    %edi,(%esp)
  100a97:	ff d5                	call   *%ebp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  100a99:	83 eb 01             	sub    $0x1,%ebx
  100a9c:	85 db                	test   %ebx,%ebx
  100a9e:	7f f0                	jg     100a90 <printnum+0xa0>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  100aa0:	89 74 24 04          	mov    %esi,0x4(%esp)
  100aa4:	8b 74 24 04          	mov    0x4(%esp),%esi
  100aa8:	8b 44 24 58          	mov    0x58(%esp),%eax
  100aac:	89 44 24 08          	mov    %eax,0x8(%esp)
  100ab0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  100ab7:	00 
  100ab8:	8b 54 24 24          	mov    0x24(%esp),%edx
  100abc:	89 14 24             	mov    %edx,(%esp)
  100abf:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  100ac3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100ac7:	e8 84 0b 00 00       	call   101650 <__umoddi3>
  100acc:	89 74 24 04          	mov    %esi,0x4(%esp)
  100ad0:	0f be 80 e8 1e 10 00 	movsbl 0x101ee8(%eax),%eax
  100ad7:	89 04 24             	mov    %eax,(%esp)
  100ada:	ff d5                	call   *%ebp
}
  100adc:	83 c4 3c             	add    $0x3c,%esp
  100adf:	5b                   	pop    %ebx
  100ae0:	5e                   	pop    %esi
  100ae1:	5f                   	pop    %edi
  100ae2:	5d                   	pop    %ebp
  100ae3:	c3                   	ret    

00100ae4 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  100ae4:	83 fa 01             	cmp    $0x1,%edx
  100ae7:	7e 0d                	jle    100af6 <getuint+0x12>
		return va_arg(*ap, unsigned long long);
  100ae9:	8b 10                	mov    (%eax),%edx
  100aeb:	8d 4a 08             	lea    0x8(%edx),%ecx
  100aee:	89 08                	mov    %ecx,(%eax)
  100af0:	8b 02                	mov    (%edx),%eax
  100af2:	8b 52 04             	mov    0x4(%edx),%edx
  100af5:	c3                   	ret    
	else if (lflag)
  100af6:	85 d2                	test   %edx,%edx
  100af8:	74 0f                	je     100b09 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  100afa:	8b 10                	mov    (%eax),%edx
  100afc:	8d 4a 04             	lea    0x4(%edx),%ecx
  100aff:	89 08                	mov    %ecx,(%eax)
  100b01:	8b 02                	mov    (%edx),%eax
  100b03:	ba 00 00 00 00       	mov    $0x0,%edx
  100b08:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  100b09:	8b 10                	mov    (%eax),%edx
  100b0b:	8d 4a 04             	lea    0x4(%edx),%ecx
  100b0e:	89 08                	mov    %ecx,(%eax)
  100b10:	8b 02                	mov    (%edx),%eax
  100b12:	ba 00 00 00 00       	mov    $0x0,%edx
}
  100b17:	c3                   	ret    

00100b18 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  100b18:	8b 44 24 08          	mov    0x8(%esp),%eax
	b->cnt++;
  100b1c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  100b20:	8b 10                	mov    (%eax),%edx
  100b22:	3b 50 04             	cmp    0x4(%eax),%edx
  100b25:	73 0b                	jae    100b32 <sprintputch+0x1a>
		*b->buf++ = ch;
  100b27:	8b 4c 24 04          	mov    0x4(%esp),%ecx
  100b2b:	88 0a                	mov    %cl,(%edx)
  100b2d:	83 c2 01             	add    $0x1,%edx
  100b30:	89 10                	mov    %edx,(%eax)
  100b32:	f3 c3                	repz ret 

00100b34 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  100b34:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;

	va_start(ap, fmt);
  100b37:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  100b3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100b3f:	8b 44 24 28          	mov    0x28(%esp),%eax
  100b43:	89 44 24 08          	mov    %eax,0x8(%esp)
  100b47:	8b 44 24 24          	mov    0x24(%esp),%eax
  100b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4f:	8b 44 24 20          	mov    0x20(%esp),%eax
  100b53:	89 04 24             	mov    %eax,(%esp)
  100b56:	e8 04 00 00 00       	call   100b5f <vprintfmt>
	va_end(ap);
}
  100b5b:	83 c4 1c             	add    $0x1c,%esp
  100b5e:	c3                   	ret    

00100b5f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  100b5f:	55                   	push   %ebp
  100b60:	57                   	push   %edi
  100b61:	56                   	push   %esi
  100b62:	53                   	push   %ebx
  100b63:	83 ec 4c             	sub    $0x4c,%esp
  100b66:	8b 6c 24 60          	mov    0x60(%esp),%ebp
  100b6a:	8b 7c 24 64          	mov    0x64(%esp),%edi
  100b6e:	8b 5c 24 68          	mov    0x68(%esp),%ebx
  100b72:	eb 11                	jmp    100b85 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  100b74:	85 c0                	test   %eax,%eax
  100b76:	0f 84 40 04 00 00    	je     100fbc <vprintfmt+0x45d>
				return;
			putch(ch, putdat);
  100b7c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100b80:	89 04 24             	mov    %eax,(%esp)
  100b83:	ff d5                	call   *%ebp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  100b85:	0f b6 03             	movzbl (%ebx),%eax
  100b88:	83 c3 01             	add    $0x1,%ebx
  100b8b:	83 f8 25             	cmp    $0x25,%eax
  100b8e:	75 e4                	jne    100b74 <vprintfmt+0x15>
  100b90:	c6 44 24 28 20       	movb   $0x20,0x28(%esp)
  100b95:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
  100b9c:	00 
  100b9d:	be ff ff ff ff       	mov    $0xffffffff,%esi
  100ba2:	c7 44 24 30 ff ff ff 	movl   $0xffffffff,0x30(%esp)
  100ba9:	ff 
  100baa:	b9 00 00 00 00       	mov    $0x0,%ecx
  100baf:	89 74 24 34          	mov    %esi,0x34(%esp)
  100bb3:	eb 34                	jmp    100be9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100bb5:	8b 5c 24 24          	mov    0x24(%esp),%ebx

		// flag to pad on the right
		case '-':
			padc = '-';
  100bb9:	c6 44 24 28 2d       	movb   $0x2d,0x28(%esp)
  100bbe:	eb 29                	jmp    100be9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100bc0:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  100bc4:	c6 44 24 28 30       	movb   $0x30,0x28(%esp)
  100bc9:	eb 1e                	jmp    100be9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100bcb:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  100bcf:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
  100bd6:	00 
  100bd7:	eb 10                	jmp    100be9 <vprintfmt+0x8a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  100bd9:	8b 44 24 34          	mov    0x34(%esp),%eax
  100bdd:	89 44 24 30          	mov    %eax,0x30(%esp)
  100be1:	c7 44 24 34 ff ff ff 	movl   $0xffffffff,0x34(%esp)
  100be8:	ff 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100be9:	0f b6 03             	movzbl (%ebx),%eax
  100bec:	0f b6 d0             	movzbl %al,%edx
  100bef:	8d 73 01             	lea    0x1(%ebx),%esi
  100bf2:	89 74 24 24          	mov    %esi,0x24(%esp)
  100bf6:	83 e8 23             	sub    $0x23,%eax
  100bf9:	3c 55                	cmp    $0x55,%al
  100bfb:	0f 87 9c 03 00 00    	ja     100f9d <vprintfmt+0x43e>
  100c01:	0f b6 c0             	movzbl %al,%eax
  100c04:	ff 24 85 a0 1f 10 00 	jmp    *0x101fa0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  100c0b:	83 ea 30             	sub    $0x30,%edx
  100c0e:	89 54 24 34          	mov    %edx,0x34(%esp)
				ch = *fmt;
  100c12:	8b 54 24 24          	mov    0x24(%esp),%edx
  100c16:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  100c19:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c1c:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  100c20:	83 fa 09             	cmp    $0x9,%edx
  100c23:	77 5b                	ja     100c80 <vprintfmt+0x121>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c25:	8b 74 24 34          	mov    0x34(%esp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  100c29:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  100c2c:	8d 14 b6             	lea    (%esi,%esi,4),%edx
  100c2f:	8d 74 50 d0          	lea    -0x30(%eax,%edx,2),%esi
				ch = *fmt;
  100c33:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  100c36:	8d 50 d0             	lea    -0x30(%eax),%edx
  100c39:	83 fa 09             	cmp    $0x9,%edx
  100c3c:	76 eb                	jbe    100c29 <vprintfmt+0xca>
  100c3e:	89 74 24 34          	mov    %esi,0x34(%esp)
  100c42:	eb 3c                	jmp    100c80 <vprintfmt+0x121>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  100c44:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100c48:	8d 50 04             	lea    0x4(%eax),%edx
  100c4b:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100c4f:	8b 00                	mov    (%eax),%eax
  100c51:	89 44 24 34          	mov    %eax,0x34(%esp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c55:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  100c59:	eb 25                	jmp    100c80 <vprintfmt+0x121>

		case '.':
			if (width < 0)
  100c5b:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
  100c60:	0f 88 65 ff ff ff    	js     100bcb <vprintfmt+0x6c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c66:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100c6a:	e9 7a ff ff ff       	jmp    100be9 <vprintfmt+0x8a>
  100c6f:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  100c73:	c7 44 24 2c 01 00 00 	movl   $0x1,0x2c(%esp)
  100c7a:	00 
			goto reswitch;
  100c7b:	e9 69 ff ff ff       	jmp    100be9 <vprintfmt+0x8a>

		process_precision:
			if (width < 0)
  100c80:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
  100c85:	0f 89 5e ff ff ff    	jns    100be9 <vprintfmt+0x8a>
  100c8b:	e9 49 ff ff ff       	jmp    100bd9 <vprintfmt+0x7a>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  100c90:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c93:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100c97:	e9 4d ff ff ff       	jmp    100be9 <vprintfmt+0x8a>
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  100c9c:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100ca0:	8d 50 04             	lea    0x4(%eax),%edx
  100ca3:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100ca7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100cab:	8b 00                	mov    (%eax),%eax
  100cad:	89 04 24             	mov    %eax,(%esp)
  100cb0:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100cb2:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  100cb6:	e9 ca fe ff ff       	jmp    100b85 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  100cbb:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100cbf:	8d 50 04             	lea    0x4(%eax),%edx
  100cc2:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100cc6:	8b 00                	mov    (%eax),%eax
  100cc8:	89 c2                	mov    %eax,%edx
  100cca:	c1 fa 1f             	sar    $0x1f,%edx
  100ccd:	31 d0                	xor    %edx,%eax
  100ccf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  100cd1:	83 f8 08             	cmp    $0x8,%eax
  100cd4:	7f 0b                	jg     100ce1 <vprintfmt+0x182>
  100cd6:	8b 14 85 00 21 10 00 	mov    0x102100(,%eax,4),%edx
  100cdd:	85 d2                	test   %edx,%edx
  100cdf:	75 21                	jne    100d02 <vprintfmt+0x1a3>
				printfmt(putch, putdat, "error %d", err);
  100ce1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100ce5:	c7 44 24 08 00 1f 10 	movl   $0x101f00,0x8(%esp)
  100cec:	00 
  100ced:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100cf1:	89 2c 24             	mov    %ebp,(%esp)
  100cf4:	e8 3b fe ff ff       	call   100b34 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100cf9:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  100cfd:	e9 83 fe ff ff       	jmp    100b85 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  100d02:	89 54 24 0c          	mov    %edx,0xc(%esp)
  100d06:	c7 44 24 08 09 1f 10 	movl   $0x101f09,0x8(%esp)
  100d0d:	00 
  100d0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100d12:	89 2c 24             	mov    %ebp,(%esp)
  100d15:	e8 1a fe ff ff       	call   100b34 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100d1a:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100d1e:	e9 62 fe ff ff       	jmp    100b85 <vprintfmt+0x26>
  100d23:	8b 74 24 34          	mov    0x34(%esp),%esi
  100d27:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100d2b:	8b 44 24 30          	mov    0x30(%esp),%eax
  100d2f:	89 44 24 38          	mov    %eax,0x38(%esp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  100d33:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100d37:	8d 50 04             	lea    0x4(%eax),%edx
  100d3a:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100d3e:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  100d40:	85 c0                	test   %eax,%eax
  100d42:	ba f9 1e 10 00       	mov    $0x101ef9,%edx
  100d47:	0f 45 d0             	cmovne %eax,%edx
  100d4a:	89 54 24 34          	mov    %edx,0x34(%esp)
			if (width > 0 && padc != '-')
  100d4e:	83 7c 24 38 00       	cmpl   $0x0,0x38(%esp)
  100d53:	7e 07                	jle    100d5c <vprintfmt+0x1fd>
  100d55:	80 7c 24 28 2d       	cmpb   $0x2d,0x28(%esp)
  100d5a:	75 14                	jne    100d70 <vprintfmt+0x211>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  100d5c:	8b 54 24 34          	mov    0x34(%esp),%edx
  100d60:	0f be 02             	movsbl (%edx),%eax
  100d63:	85 c0                	test   %eax,%eax
  100d65:	0f 85 ac 00 00 00    	jne    100e17 <vprintfmt+0x2b8>
  100d6b:	e9 97 00 00 00       	jmp    100e07 <vprintfmt+0x2a8>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  100d70:	89 74 24 04          	mov    %esi,0x4(%esp)
  100d74:	8b 44 24 34          	mov    0x34(%esp),%eax
  100d78:	89 04 24             	mov    %eax,(%esp)
  100d7b:	e8 99 03 00 00       	call   101119 <strnlen>
  100d80:	8b 54 24 38          	mov    0x38(%esp),%edx
  100d84:	29 c2                	sub    %eax,%edx
  100d86:	89 54 24 30          	mov    %edx,0x30(%esp)
  100d8a:	85 d2                	test   %edx,%edx
  100d8c:	7e ce                	jle    100d5c <vprintfmt+0x1fd>
					putch(padc, putdat);
  100d8e:	0f be 44 24 28       	movsbl 0x28(%esp),%eax
  100d93:	89 74 24 38          	mov    %esi,0x38(%esp)
  100d97:	89 5c 24 3c          	mov    %ebx,0x3c(%esp)
  100d9b:	89 d3                	mov    %edx,%ebx
  100d9d:	89 c6                	mov    %eax,%esi
  100d9f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100da3:	89 34 24             	mov    %esi,(%esp)
  100da6:	ff d5                	call   *%ebp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  100da8:	83 eb 01             	sub    $0x1,%ebx
  100dab:	85 db                	test   %ebx,%ebx
  100dad:	7f f0                	jg     100d9f <vprintfmt+0x240>
  100daf:	8b 74 24 38          	mov    0x38(%esp),%esi
  100db3:	8b 5c 24 3c          	mov    0x3c(%esp),%ebx
  100db7:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
  100dbe:	00 
  100dbf:	eb 9b                	jmp    100d5c <vprintfmt+0x1fd>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  100dc1:	83 7c 24 2c 00       	cmpl   $0x0,0x2c(%esp)
  100dc6:	74 19                	je     100de1 <vprintfmt+0x282>
  100dc8:	8d 50 e0             	lea    -0x20(%eax),%edx
  100dcb:	83 fa 5e             	cmp    $0x5e,%edx
  100dce:	76 11                	jbe    100de1 <vprintfmt+0x282>
					putch('?', putdat);
  100dd0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100dd4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  100ddb:	ff 54 24 28          	call   *0x28(%esp)
  100ddf:	eb 0b                	jmp    100dec <vprintfmt+0x28d>
				else
					putch(ch, putdat);
  100de1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100de5:	89 04 24             	mov    %eax,(%esp)
  100de8:	ff 54 24 28          	call   *0x28(%esp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  100dec:	83 ed 01             	sub    $0x1,%ebp
  100def:	0f be 03             	movsbl (%ebx),%eax
  100df2:	85 c0                	test   %eax,%eax
  100df4:	74 05                	je     100dfb <vprintfmt+0x29c>
  100df6:	83 c3 01             	add    $0x1,%ebx
  100df9:	eb 31                	jmp    100e2c <vprintfmt+0x2cd>
  100dfb:	89 6c 24 30          	mov    %ebp,0x30(%esp)
  100dff:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  100e03:	8b 5c 24 38          	mov    0x38(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  100e07:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
  100e0c:	7f 35                	jg     100e43 <vprintfmt+0x2e4>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100e0e:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100e12:	e9 6e fd ff ff       	jmp    100b85 <vprintfmt+0x26>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  100e17:	8b 54 24 34          	mov    0x34(%esp),%edx
  100e1b:	83 c2 01             	add    $0x1,%edx
  100e1e:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  100e22:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  100e26:	89 5c 24 38          	mov    %ebx,0x38(%esp)
  100e2a:	89 d3                	mov    %edx,%ebx
  100e2c:	85 f6                	test   %esi,%esi
  100e2e:	78 91                	js     100dc1 <vprintfmt+0x262>
  100e30:	83 ee 01             	sub    $0x1,%esi
  100e33:	79 8c                	jns    100dc1 <vprintfmt+0x262>
  100e35:	89 6c 24 30          	mov    %ebp,0x30(%esp)
  100e39:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  100e3d:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  100e41:	eb c4                	jmp    100e07 <vprintfmt+0x2a8>
  100e43:	89 de                	mov    %ebx,%esi
  100e45:	8b 5c 24 30          	mov    0x30(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  100e49:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100e4d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  100e54:	ff d5                	call   *%ebp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  100e56:	83 eb 01             	sub    $0x1,%ebx
  100e59:	85 db                	test   %ebx,%ebx
  100e5b:	7f ec                	jg     100e49 <vprintfmt+0x2ea>
  100e5d:	89 f3                	mov    %esi,%ebx
  100e5f:	e9 21 fd ff ff       	jmp    100b85 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  100e64:	83 f9 01             	cmp    $0x1,%ecx
  100e67:	7e 12                	jle    100e7b <vprintfmt+0x31c>
		return va_arg(*ap, long long);
  100e69:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100e6d:	8d 50 08             	lea    0x8(%eax),%edx
  100e70:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100e74:	8b 18                	mov    (%eax),%ebx
  100e76:	8b 70 04             	mov    0x4(%eax),%esi
  100e79:	eb 2a                	jmp    100ea5 <vprintfmt+0x346>
	else if (lflag)
  100e7b:	85 c9                	test   %ecx,%ecx
  100e7d:	74 14                	je     100e93 <vprintfmt+0x334>
		return va_arg(*ap, long);
  100e7f:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100e83:	8d 50 04             	lea    0x4(%eax),%edx
  100e86:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100e8a:	8b 18                	mov    (%eax),%ebx
  100e8c:	89 de                	mov    %ebx,%esi
  100e8e:	c1 fe 1f             	sar    $0x1f,%esi
  100e91:	eb 12                	jmp    100ea5 <vprintfmt+0x346>
	else
		return va_arg(*ap, int);
  100e93:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100e97:	8d 50 04             	lea    0x4(%eax),%edx
  100e9a:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100e9e:	8b 18                	mov    (%eax),%ebx
  100ea0:	89 de                	mov    %ebx,%esi
  100ea2:	c1 fe 1f             	sar    $0x1f,%esi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  100ea5:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  100eaa:	85 f6                	test   %esi,%esi
  100eac:	0f 89 ab 00 00 00    	jns    100f5d <vprintfmt+0x3fe>
				putch('-', putdat);
  100eb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100eb6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  100ebd:	ff d5                	call   *%ebp
				num = -(long long) num;
  100ebf:	f7 db                	neg    %ebx
  100ec1:	83 d6 00             	adc    $0x0,%esi
  100ec4:	f7 de                	neg    %esi
			}
			base = 10;
  100ec6:	b8 0a 00 00 00       	mov    $0xa,%eax
  100ecb:	e9 8d 00 00 00       	jmp    100f5d <vprintfmt+0x3fe>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  100ed0:	89 ca                	mov    %ecx,%edx
  100ed2:	8d 44 24 6c          	lea    0x6c(%esp),%eax
  100ed6:	e8 09 fc ff ff       	call   100ae4 <getuint>
  100edb:	89 c3                	mov    %eax,%ebx
  100edd:	89 d6                	mov    %edx,%esi
			base = 10;
  100edf:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  100ee4:	eb 77                	jmp    100f5d <vprintfmt+0x3fe>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  100ee6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100eea:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  100ef1:	ff d5                	call   *%ebp
			putch('X', putdat);
  100ef3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100ef7:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  100efe:	ff d5                	call   *%ebp
			putch('X', putdat);
  100f00:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100f04:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  100f0b:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100f0d:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  100f11:	e9 6f fc ff ff       	jmp    100b85 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  100f16:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100f1a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  100f21:	ff d5                	call   *%ebp
			putch('x', putdat);
  100f23:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100f27:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  100f2e:	ff d5                	call   *%ebp
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  100f30:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100f34:	8d 50 04             	lea    0x4(%eax),%edx
  100f37:	89 54 24 6c          	mov    %edx,0x6c(%esp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  100f3b:	8b 18                	mov    (%eax),%ebx
  100f3d:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  100f42:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  100f47:	eb 14                	jmp    100f5d <vprintfmt+0x3fe>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  100f49:	89 ca                	mov    %ecx,%edx
  100f4b:	8d 44 24 6c          	lea    0x6c(%esp),%eax
  100f4f:	e8 90 fb ff ff       	call   100ae4 <getuint>
  100f54:	89 c3                	mov    %eax,%ebx
  100f56:	89 d6                	mov    %edx,%esi
			base = 16;
  100f58:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  100f5d:	0f be 54 24 28       	movsbl 0x28(%esp),%edx
  100f62:	89 54 24 10          	mov    %edx,0x10(%esp)
  100f66:	8b 54 24 30          	mov    0x30(%esp),%edx
  100f6a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  100f6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  100f72:	89 1c 24             	mov    %ebx,(%esp)
  100f75:	89 74 24 04          	mov    %esi,0x4(%esp)
  100f79:	89 fa                	mov    %edi,%edx
  100f7b:	89 e8                	mov    %ebp,%eax
  100f7d:	e8 6e fa ff ff       	call   1009f0 <printnum>
			break;
  100f82:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100f86:	e9 fa fb ff ff       	jmp    100b85 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  100f8b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100f8f:	89 14 24             	mov    %edx,(%esp)
  100f92:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100f94:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  100f98:	e9 e8 fb ff ff       	jmp    100b85 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  100f9d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100fa1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  100fa8:	ff d5                	call   *%ebp
			for (fmt--; fmt[-1] != '%'; fmt--)
  100faa:	eb 02                	jmp    100fae <vprintfmt+0x44f>
  100fac:	89 c3                	mov    %eax,%ebx
  100fae:	8d 43 ff             	lea    -0x1(%ebx),%eax
  100fb1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  100fb5:	75 f5                	jne    100fac <vprintfmt+0x44d>
  100fb7:	e9 c9 fb ff ff       	jmp    100b85 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  100fbc:	83 c4 4c             	add    $0x4c,%esp
  100fbf:	5b                   	pop    %ebx
  100fc0:	5e                   	pop    %esi
  100fc1:	5f                   	pop    %edi
  100fc2:	5d                   	pop    %ebp
  100fc3:	c3                   	ret    

00100fc4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  100fc4:	83 ec 2c             	sub    $0x2c,%esp
  100fc7:	8b 44 24 30          	mov    0x30(%esp),%eax
  100fcb:	8b 54 24 34          	mov    0x34(%esp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  100fcf:	89 44 24 14          	mov    %eax,0x14(%esp)
  100fd3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  100fd7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  100fdb:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  100fe2:	00 

	if (buf == NULL || n < 1)
  100fe3:	85 c0                	test   %eax,%eax
  100fe5:	74 35                	je     10101c <vsnprintf+0x58>
  100fe7:	85 d2                	test   %edx,%edx
  100fe9:	7e 31                	jle    10101c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  100feb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  100fef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100ff3:	8b 44 24 38          	mov    0x38(%esp),%eax
  100ff7:	89 44 24 08          	mov    %eax,0x8(%esp)
  100ffb:	8d 44 24 14          	lea    0x14(%esp),%eax
  100fff:	89 44 24 04          	mov    %eax,0x4(%esp)
  101003:	c7 04 24 18 0b 10 00 	movl   $0x100b18,(%esp)
  10100a:	e8 50 fb ff ff       	call   100b5f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  10100f:	8b 44 24 14          	mov    0x14(%esp),%eax
  101013:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  101016:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  10101a:	eb 05                	jmp    101021 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  10101c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  101021:	83 c4 2c             	add    $0x2c,%esp
  101024:	c3                   	ret    

00101025 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  101025:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  101028:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  10102c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  101030:	8b 44 24 28          	mov    0x28(%esp),%eax
  101034:	89 44 24 08          	mov    %eax,0x8(%esp)
  101038:	8b 44 24 24          	mov    0x24(%esp),%eax
  10103c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101040:	8b 44 24 20          	mov    0x20(%esp),%eax
  101044:	89 04 24             	mov    %eax,(%esp)
  101047:	e8 78 ff ff ff       	call   100fc4 <vsnprintf>
	va_end(ap);

	return rc;
}
  10104c:	83 c4 1c             	add    $0x1c,%esp
  10104f:	c3                   	ret    

00101050 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
  101050:	56                   	push   %esi
  101051:	53                   	push   %ebx
  101052:	83 ec 14             	sub    $0x14,%esp
  101055:	8b 44 24 20          	mov    0x20(%esp),%eax
	int i, c, echoing;

	if (prompt != NULL)
  101059:	85 c0                	test   %eax,%eax
  10105b:	74 10                	je     10106d <readline+0x1d>
		cprintf("%s", prompt);
  10105d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101061:	c7 04 24 09 1f 10 00 	movl   $0x101f09,(%esp)
  101068:	e8 e9 f6 ff ff       	call   100756 <cprintf>

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
  10106d:	be 00 00 00 00       	mov    $0x0,%esi
	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
	while (1) {
		c = getc();
  101072:	e8 ec f1 ff ff       	call   100263 <getc>
  101077:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  101079:	85 c0                	test   %eax,%eax
  10107b:	79 17                	jns    101094 <readline+0x44>
			cprintf("read error: %e\n", c);
  10107d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101081:	c7 04 24 24 21 10 00 	movl   $0x102124,(%esp)
  101088:	e8 c9 f6 ff ff       	call   100756 <cprintf>
			return NULL;
  10108d:	b8 00 00 00 00       	mov    $0x0,%eax
  101092:	eb 64                	jmp    1010f8 <readline+0xa8>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  101094:	83 f8 08             	cmp    $0x8,%eax
  101097:	74 05                	je     10109e <readline+0x4e>
  101099:	83 f8 7f             	cmp    $0x7f,%eax
  10109c:	75 15                	jne    1010b3 <readline+0x63>
  10109e:	85 f6                	test   %esi,%esi
  1010a0:	7e 11                	jle    1010b3 <readline+0x63>
			putch('\b');
  1010a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010a9:	e8 b3 f2 ff ff       	call   100361 <putch>
			i--;
  1010ae:	83 ee 01             	sub    $0x1,%esi
  1010b1:	eb bf                	jmp    101072 <readline+0x22>
		} else if (c >= ' ' && i < BUFLEN-1) {
  1010b3:	83 fb 1f             	cmp    $0x1f,%ebx
  1010b6:	7e 1e                	jle    1010d6 <readline+0x86>
  1010b8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  1010be:	7f 16                	jg     1010d6 <readline+0x86>
			putch(c);
  1010c0:	0f b6 c3             	movzbl %bl,%eax
  1010c3:	89 04 24             	mov    %eax,(%esp)
  1010c6:	e8 96 f2 ff ff       	call   100361 <putch>
			buf[i++] = c;
  1010cb:	88 9e 40 b5 10 00    	mov    %bl,0x10b540(%esi)
  1010d1:	83 c6 01             	add    $0x1,%esi
  1010d4:	eb 9c                	jmp    101072 <readline+0x22>
		} else if (c == '\n' || c == '\r') {
  1010d6:	83 fb 0a             	cmp    $0xa,%ebx
  1010d9:	74 05                	je     1010e0 <readline+0x90>
  1010db:	83 fb 0d             	cmp    $0xd,%ebx
  1010de:	75 92                	jne    101072 <readline+0x22>
			putch('\n');
  1010e0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1010e7:	e8 75 f2 ff ff       	call   100361 <putch>
			buf[i] = 0;
  1010ec:	c6 86 40 b5 10 00 00 	movb   $0x0,0x10b540(%esi)
			return buf;
  1010f3:	b8 40 b5 10 00       	mov    $0x10b540,%eax
		}
	}
}
  1010f8:	83 c4 14             	add    $0x14,%esp
  1010fb:	5b                   	pop    %ebx
  1010fc:	5e                   	pop    %esi
  1010fd:	c3                   	ret    
	...

00101100 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  101100:	8b 54 24 04          	mov    0x4(%esp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  101104:	b8 00 00 00 00       	mov    $0x0,%eax
  101109:	80 3a 00             	cmpb   $0x0,(%edx)
  10110c:	74 09                	je     101117 <strlen+0x17>
		n++;
  10110e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  101111:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  101115:	75 f7                	jne    10110e <strlen+0xe>
		n++;
	return n;
}
  101117:	f3 c3                	repz ret 

00101119 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  101119:	8b 4c 24 04          	mov    0x4(%esp),%ecx
  10111d:	8b 54 24 08          	mov    0x8(%esp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  101121:	b8 00 00 00 00       	mov    $0x0,%eax
  101126:	85 d2                	test   %edx,%edx
  101128:	74 12                	je     10113c <strnlen+0x23>
  10112a:	80 39 00             	cmpb   $0x0,(%ecx)
  10112d:	74 0d                	je     10113c <strnlen+0x23>
		n++;
  10112f:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  101132:	39 d0                	cmp    %edx,%eax
  101134:	74 06                	je     10113c <strnlen+0x23>
  101136:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  10113a:	75 f3                	jne    10112f <strnlen+0x16>
		n++;
	return n;
}
  10113c:	f3 c3                	repz ret 

0010113e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  10113e:	53                   	push   %ebx
  10113f:	8b 44 24 08          	mov    0x8(%esp),%eax
  101143:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  101147:	ba 00 00 00 00       	mov    $0x0,%edx
  10114c:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  101150:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  101153:	83 c2 01             	add    $0x1,%edx
  101156:	84 c9                	test   %cl,%cl
  101158:	75 f2                	jne    10114c <strcpy+0xe>
		/* do nothing */;
	return ret;
}
  10115a:	5b                   	pop    %ebx
  10115b:	c3                   	ret    

0010115c <strcat>:

char *
strcat(char *dst, const char *src)
{
  10115c:	53                   	push   %ebx
  10115d:	83 ec 08             	sub    $0x8,%esp
  101160:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	int len = strlen(dst);
  101164:	89 1c 24             	mov    %ebx,(%esp)
  101167:	e8 94 ff ff ff       	call   101100 <strlen>
	strcpy(dst + len, src);
  10116c:	8b 54 24 14          	mov    0x14(%esp),%edx
  101170:	89 54 24 04          	mov    %edx,0x4(%esp)
  101174:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  101177:	89 04 24             	mov    %eax,(%esp)
  10117a:	e8 bf ff ff ff       	call   10113e <strcpy>
	return dst;
}
  10117f:	89 d8                	mov    %ebx,%eax
  101181:	83 c4 08             	add    $0x8,%esp
  101184:	5b                   	pop    %ebx
  101185:	c3                   	ret    

00101186 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  101186:	56                   	push   %esi
  101187:	53                   	push   %ebx
  101188:	8b 44 24 0c          	mov    0xc(%esp),%eax
  10118c:	8b 54 24 10          	mov    0x10(%esp),%edx
  101190:	8b 74 24 14          	mov    0x14(%esp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  101194:	85 f6                	test   %esi,%esi
  101196:	74 18                	je     1011b0 <strncpy+0x2a>
  101198:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  10119d:	0f b6 1a             	movzbl (%edx),%ebx
  1011a0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  1011a3:	80 3a 01             	cmpb   $0x1,(%edx)
  1011a6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  1011a9:	83 c1 01             	add    $0x1,%ecx
  1011ac:	39 ce                	cmp    %ecx,%esi
  1011ae:	77 ed                	ja     10119d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  1011b0:	5b                   	pop    %ebx
  1011b1:	5e                   	pop    %esi
  1011b2:	c3                   	ret    

001011b3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  1011b3:	57                   	push   %edi
  1011b4:	56                   	push   %esi
  1011b5:	53                   	push   %ebx
  1011b6:	8b 7c 24 10          	mov    0x10(%esp),%edi
  1011ba:	8b 5c 24 14          	mov    0x14(%esp),%ebx
  1011be:	8b 74 24 18          	mov    0x18(%esp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  1011c2:	89 f8                	mov    %edi,%eax
  1011c4:	85 f6                	test   %esi,%esi
  1011c6:	74 2c                	je     1011f4 <strlcpy+0x41>
		while (--size > 0 && *src != '\0')
  1011c8:	83 fe 01             	cmp    $0x1,%esi
  1011cb:	74 24                	je     1011f1 <strlcpy+0x3e>
  1011cd:	0f b6 0b             	movzbl (%ebx),%ecx
  1011d0:	84 c9                	test   %cl,%cl
  1011d2:	74 1d                	je     1011f1 <strlcpy+0x3e>
  1011d4:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  1011d9:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  1011dc:	88 08                	mov    %cl,(%eax)
  1011de:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  1011e1:	39 f2                	cmp    %esi,%edx
  1011e3:	74 0c                	je     1011f1 <strlcpy+0x3e>
  1011e5:	0f b6 4c 13 01       	movzbl 0x1(%ebx,%edx,1),%ecx
  1011ea:	83 c2 01             	add    $0x1,%edx
  1011ed:	84 c9                	test   %cl,%cl
  1011ef:	75 eb                	jne    1011dc <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  1011f1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  1011f4:	29 f8                	sub    %edi,%eax
}
  1011f6:	5b                   	pop    %ebx
  1011f7:	5e                   	pop    %esi
  1011f8:	5f                   	pop    %edi
  1011f9:	c3                   	ret    

001011fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  1011fa:	8b 4c 24 04          	mov    0x4(%esp),%ecx
  1011fe:	8b 54 24 08          	mov    0x8(%esp),%edx
	while (*p && *p == *q)
  101202:	0f b6 01             	movzbl (%ecx),%eax
  101205:	84 c0                	test   %al,%al
  101207:	74 15                	je     10121e <strcmp+0x24>
  101209:	3a 02                	cmp    (%edx),%al
  10120b:	75 11                	jne    10121e <strcmp+0x24>
		p++, q++;
  10120d:	83 c1 01             	add    $0x1,%ecx
  101210:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  101213:	0f b6 01             	movzbl (%ecx),%eax
  101216:	84 c0                	test   %al,%al
  101218:	74 04                	je     10121e <strcmp+0x24>
  10121a:	3a 02                	cmp    (%edx),%al
  10121c:	74 ef                	je     10120d <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  10121e:	0f b6 c0             	movzbl %al,%eax
  101221:	0f b6 12             	movzbl (%edx),%edx
  101224:	29 d0                	sub    %edx,%eax
}
  101226:	c3                   	ret    

00101227 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  101227:	53                   	push   %ebx
  101228:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  10122c:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  101230:	8b 54 24 10          	mov    0x10(%esp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  101234:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  101239:	85 d2                	test   %edx,%edx
  10123b:	74 28                	je     101265 <strncmp+0x3e>
  10123d:	0f b6 01             	movzbl (%ecx),%eax
  101240:	84 c0                	test   %al,%al
  101242:	74 23                	je     101267 <strncmp+0x40>
  101244:	3a 03                	cmp    (%ebx),%al
  101246:	75 1f                	jne    101267 <strncmp+0x40>
  101248:	83 ea 01             	sub    $0x1,%edx
  10124b:	74 13                	je     101260 <strncmp+0x39>
		n--, p++, q++;
  10124d:	83 c1 01             	add    $0x1,%ecx
  101250:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  101253:	0f b6 01             	movzbl (%ecx),%eax
  101256:	84 c0                	test   %al,%al
  101258:	74 0d                	je     101267 <strncmp+0x40>
  10125a:	3a 03                	cmp    (%ebx),%al
  10125c:	74 ea                	je     101248 <strncmp+0x21>
  10125e:	eb 07                	jmp    101267 <strncmp+0x40>
		n--, p++, q++;
	if (n == 0)
		return 0;
  101260:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  101265:	5b                   	pop    %ebx
  101266:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  101267:	0f b6 01             	movzbl (%ecx),%eax
  10126a:	0f b6 13             	movzbl (%ebx),%edx
  10126d:	29 d0                	sub    %edx,%eax
  10126f:	eb f4                	jmp    101265 <strncmp+0x3e>

00101271 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  101271:	8b 44 24 04          	mov    0x4(%esp),%eax
  101275:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
  10127a:	0f b6 10             	movzbl (%eax),%edx
  10127d:	84 d2                	test   %dl,%dl
  10127f:	74 21                	je     1012a2 <strchr+0x31>
		if (*s == c)
  101281:	38 ca                	cmp    %cl,%dl
  101283:	75 0d                	jne    101292 <strchr+0x21>
  101285:	f3 c3                	repz ret 
  101287:	38 ca                	cmp    %cl,%dl
  101289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  101290:	74 15                	je     1012a7 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  101292:	83 c0 01             	add    $0x1,%eax
  101295:	0f b6 10             	movzbl (%eax),%edx
  101298:	84 d2                	test   %dl,%dl
  10129a:	75 eb                	jne    101287 <strchr+0x16>
		if (*s == c)
			return (char *) s;
	return 0;
  10129c:	b8 00 00 00 00       	mov    $0x0,%eax
  1012a1:	c3                   	ret    
  1012a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1012a7:	f3 c3                	repz ret 

001012a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  1012a9:	8b 44 24 04          	mov    0x4(%esp),%eax
  1012ad:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
  1012b2:	0f b6 10             	movzbl (%eax),%edx
  1012b5:	84 d2                	test   %dl,%dl
  1012b7:	74 14                	je     1012cd <strfind+0x24>
		if (*s == c)
  1012b9:	38 ca                	cmp    %cl,%dl
  1012bb:	75 06                	jne    1012c3 <strfind+0x1a>
  1012bd:	f3 c3                	repz ret 
  1012bf:	38 ca                	cmp    %cl,%dl
  1012c1:	74 0a                	je     1012cd <strfind+0x24>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  1012c3:	83 c0 01             	add    $0x1,%eax
  1012c6:	0f b6 10             	movzbl (%eax),%edx
  1012c9:	84 d2                	test   %dl,%dl
  1012cb:	75 f2                	jne    1012bf <strfind+0x16>
		if (*s == c)
			break;
	return (char *) s;
}
  1012cd:	f3 c3                	repz ret 

001012cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  1012cf:	83 ec 0c             	sub    $0xc,%esp
  1012d2:	89 1c 24             	mov    %ebx,(%esp)
  1012d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  1012d9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  1012dd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  1012e1:	8b 44 24 14          	mov    0x14(%esp),%eax
  1012e5:	8b 4c 24 18          	mov    0x18(%esp),%ecx
	char *p;

	if (n == 0)
  1012e9:	85 c9                	test   %ecx,%ecx
  1012eb:	74 30                	je     10131d <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  1012ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  1012f3:	75 25                	jne    10131a <memset+0x4b>
  1012f5:	f6 c1 03             	test   $0x3,%cl
  1012f8:	75 20                	jne    10131a <memset+0x4b>
		c &= 0xFF;
  1012fa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  1012fd:	89 d3                	mov    %edx,%ebx
  1012ff:	c1 e3 08             	shl    $0x8,%ebx
  101302:	89 d6                	mov    %edx,%esi
  101304:	c1 e6 18             	shl    $0x18,%esi
  101307:	89 d0                	mov    %edx,%eax
  101309:	c1 e0 10             	shl    $0x10,%eax
  10130c:	09 f0                	or     %esi,%eax
  10130e:	09 d0                	or     %edx,%eax
  101310:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  101312:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  101315:	fc                   	cld    
  101316:	f3 ab                	rep stos %eax,%es:(%edi)
  101318:	eb 03                	jmp    10131d <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  10131a:	fc                   	cld    
  10131b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  10131d:	89 f8                	mov    %edi,%eax
  10131f:	8b 1c 24             	mov    (%esp),%ebx
  101322:	8b 74 24 04          	mov    0x4(%esp),%esi
  101326:	8b 7c 24 08          	mov    0x8(%esp),%edi
  10132a:	83 c4 0c             	add    $0xc,%esp
  10132d:	c3                   	ret    

0010132e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  10132e:	83 ec 08             	sub    $0x8,%esp
  101331:	89 34 24             	mov    %esi,(%esp)
  101334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  101338:	8b 44 24 0c          	mov    0xc(%esp),%eax
  10133c:	8b 74 24 10          	mov    0x10(%esp),%esi
  101340:	8b 4c 24 14          	mov    0x14(%esp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  101344:	39 c6                	cmp    %eax,%esi
  101346:	73 36                	jae    10137e <memmove+0x50>
  101348:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  10134b:	39 d0                	cmp    %edx,%eax
  10134d:	73 2f                	jae    10137e <memmove+0x50>
		s += n;
		d += n;
  10134f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  101352:	f6 c2 03             	test   $0x3,%dl
  101355:	75 1b                	jne    101372 <memmove+0x44>
  101357:	f7 c7 03 00 00 00    	test   $0x3,%edi
  10135d:	75 13                	jne    101372 <memmove+0x44>
  10135f:	f6 c1 03             	test   $0x3,%cl
  101362:	75 0e                	jne    101372 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  101364:	83 ef 04             	sub    $0x4,%edi
  101367:	8d 72 fc             	lea    -0x4(%edx),%esi
  10136a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  10136d:	fd                   	std    
  10136e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  101370:	eb 09                	jmp    10137b <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  101372:	83 ef 01             	sub    $0x1,%edi
  101375:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  101378:	fd                   	std    
  101379:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  10137b:	fc                   	cld    
  10137c:	eb 20                	jmp    10139e <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10137e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  101384:	75 13                	jne    101399 <memmove+0x6b>
  101386:	a8 03                	test   $0x3,%al
  101388:	75 0f                	jne    101399 <memmove+0x6b>
  10138a:	f6 c1 03             	test   $0x3,%cl
  10138d:	75 0a                	jne    101399 <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  10138f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  101392:	89 c7                	mov    %eax,%edi
  101394:	fc                   	cld    
  101395:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  101397:	eb 05                	jmp    10139e <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  101399:	89 c7                	mov    %eax,%edi
  10139b:	fc                   	cld    
  10139c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  10139e:	8b 34 24             	mov    (%esp),%esi
  1013a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  1013a5:	83 c4 08             	add    $0x8,%esp
  1013a8:	c3                   	ret    

001013a9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  1013a9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  1013ac:	8b 44 24 18          	mov    0x18(%esp),%eax
  1013b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1013b4:	8b 44 24 14          	mov    0x14(%esp),%eax
  1013b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1013bc:	8b 44 24 10          	mov    0x10(%esp),%eax
  1013c0:	89 04 24             	mov    %eax,(%esp)
  1013c3:	e8 66 ff ff ff       	call   10132e <memmove>
}
  1013c8:	83 c4 0c             	add    $0xc,%esp
  1013cb:	c3                   	ret    

001013cc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  1013cc:	57                   	push   %edi
  1013cd:	56                   	push   %esi
  1013ce:	53                   	push   %ebx
  1013cf:	8b 5c 24 10          	mov    0x10(%esp),%ebx
  1013d3:	8b 74 24 14          	mov    0x14(%esp),%esi
  1013d7:	8b 7c 24 18          	mov    0x18(%esp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  1013db:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  1013e0:	85 ff                	test   %edi,%edi
  1013e2:	74 38                	je     10141c <memcmp+0x50>
		if (*s1 != *s2)
  1013e4:	0f b6 03             	movzbl (%ebx),%eax
  1013e7:	0f b6 0e             	movzbl (%esi),%ecx
  1013ea:	38 c8                	cmp    %cl,%al
  1013ec:	74 1d                	je     10140b <memcmp+0x3f>
  1013ee:	eb 11                	jmp    101401 <memcmp+0x35>
  1013f0:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  1013f5:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  1013fa:	83 c2 01             	add    $0x1,%edx
  1013fd:	38 c8                	cmp    %cl,%al
  1013ff:	74 12                	je     101413 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  101401:	0f b6 c0             	movzbl %al,%eax
  101404:	0f b6 c9             	movzbl %cl,%ecx
  101407:	29 c8                	sub    %ecx,%eax
  101409:	eb 11                	jmp    10141c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  10140b:	83 ef 01             	sub    $0x1,%edi
  10140e:	ba 00 00 00 00       	mov    $0x0,%edx
  101413:	39 fa                	cmp    %edi,%edx
  101415:	75 d9                	jne    1013f0 <memcmp+0x24>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  101417:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10141c:	5b                   	pop    %ebx
  10141d:	5e                   	pop    %esi
  10141e:	5f                   	pop    %edi
  10141f:	c3                   	ret    

00101420 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  101420:	8b 44 24 04          	mov    0x4(%esp),%eax
	const void *ends = (const char *) s + n;
  101424:	89 c2                	mov    %eax,%edx
  101426:	03 54 24 0c          	add    0xc(%esp),%edx
	for (; s < ends; s++)
  10142a:	39 d0                	cmp    %edx,%eax
  10142c:	73 16                	jae    101444 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  10142e:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
  101433:	38 08                	cmp    %cl,(%eax)
  101435:	75 06                	jne    10143d <memfind+0x1d>
  101437:	f3 c3                	repz ret 
  101439:	38 08                	cmp    %cl,(%eax)
  10143b:	74 07                	je     101444 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  10143d:	83 c0 01             	add    $0x1,%eax
  101440:	39 c2                	cmp    %eax,%edx
  101442:	77 f5                	ja     101439 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  101444:	f3 c3                	repz ret 

00101446 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  101446:	55                   	push   %ebp
  101447:	57                   	push   %edi
  101448:	56                   	push   %esi
  101449:	53                   	push   %ebx
  10144a:	8b 54 24 14          	mov    0x14(%esp),%edx
  10144e:	8b 74 24 18          	mov    0x18(%esp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  101452:	0f b6 02             	movzbl (%edx),%eax
  101455:	3c 20                	cmp    $0x20,%al
  101457:	74 04                	je     10145d <strtol+0x17>
  101459:	3c 09                	cmp    $0x9,%al
  10145b:	75 0e                	jne    10146b <strtol+0x25>
		s++;
  10145d:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  101460:	0f b6 02             	movzbl (%edx),%eax
  101463:	3c 20                	cmp    $0x20,%al
  101465:	74 f6                	je     10145d <strtol+0x17>
  101467:	3c 09                	cmp    $0x9,%al
  101469:	74 f2                	je     10145d <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  10146b:	3c 2b                	cmp    $0x2b,%al
  10146d:	75 0a                	jne    101479 <strtol+0x33>
		s++;
  10146f:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  101472:	bf 00 00 00 00       	mov    $0x0,%edi
  101477:	eb 10                	jmp    101489 <strtol+0x43>
  101479:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  10147e:	3c 2d                	cmp    $0x2d,%al
  101480:	75 07                	jne    101489 <strtol+0x43>
		s++, neg = 1;
  101482:	83 c2 01             	add    $0x1,%edx
  101485:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  101489:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  10148e:	0f 94 c0             	sete   %al
  101491:	74 07                	je     10149a <strtol+0x54>
  101493:	83 7c 24 1c 10       	cmpl   $0x10,0x1c(%esp)
  101498:	75 18                	jne    1014b2 <strtol+0x6c>
  10149a:	80 3a 30             	cmpb   $0x30,(%edx)
  10149d:	75 13                	jne    1014b2 <strtol+0x6c>
  10149f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  1014a3:	75 0d                	jne    1014b2 <strtol+0x6c>
		s += 2, base = 16;
  1014a5:	83 c2 02             	add    $0x2,%edx
  1014a8:	c7 44 24 1c 10 00 00 	movl   $0x10,0x1c(%esp)
  1014af:	00 
  1014b0:	eb 1c                	jmp    1014ce <strtol+0x88>
	else if (base == 0 && s[0] == '0')
  1014b2:	84 c0                	test   %al,%al
  1014b4:	74 18                	je     1014ce <strtol+0x88>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  1014b6:	c7 44 24 1c 0a 00 00 	movl   $0xa,0x1c(%esp)
  1014bd:	00 
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  1014be:	80 3a 30             	cmpb   $0x30,(%edx)
  1014c1:	75 0b                	jne    1014ce <strtol+0x88>
		s++, base = 8;
  1014c3:	83 c2 01             	add    $0x1,%edx
  1014c6:	c7 44 24 1c 08 00 00 	movl   $0x8,0x1c(%esp)
  1014cd:	00 
	else if (base == 0)
		base = 10;
  1014ce:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  1014d3:	0f b6 0a             	movzbl (%edx),%ecx
  1014d6:	8d 69 d0             	lea    -0x30(%ecx),%ebp
  1014d9:	89 eb                	mov    %ebp,%ebx
  1014db:	80 fb 09             	cmp    $0x9,%bl
  1014de:	77 08                	ja     1014e8 <strtol+0xa2>
			dig = *s - '0';
  1014e0:	0f be c9             	movsbl %cl,%ecx
  1014e3:	83 e9 30             	sub    $0x30,%ecx
  1014e6:	eb 22                	jmp    10150a <strtol+0xc4>
		else if (*s >= 'a' && *s <= 'z')
  1014e8:	8d 69 9f             	lea    -0x61(%ecx),%ebp
  1014eb:	89 eb                	mov    %ebp,%ebx
  1014ed:	80 fb 19             	cmp    $0x19,%bl
  1014f0:	77 08                	ja     1014fa <strtol+0xb4>
			dig = *s - 'a' + 10;
  1014f2:	0f be c9             	movsbl %cl,%ecx
  1014f5:	83 e9 57             	sub    $0x57,%ecx
  1014f8:	eb 10                	jmp    10150a <strtol+0xc4>
		else if (*s >= 'A' && *s <= 'Z')
  1014fa:	8d 69 bf             	lea    -0x41(%ecx),%ebp
  1014fd:	89 eb                	mov    %ebp,%ebx
  1014ff:	80 fb 19             	cmp    $0x19,%bl
  101502:	77 19                	ja     10151d <strtol+0xd7>
			dig = *s - 'A' + 10;
  101504:	0f be c9             	movsbl %cl,%ecx
  101507:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  10150a:	3b 4c 24 1c          	cmp    0x1c(%esp),%ecx
  10150e:	7d 11                	jge    101521 <strtol+0xdb>
			break;
		s++, val = (val * base) + dig;
  101510:	83 c2 01             	add    $0x1,%edx
  101513:	0f af 44 24 1c       	imul   0x1c(%esp),%eax
  101518:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  10151b:	eb b6                	jmp    1014d3 <strtol+0x8d>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  10151d:	89 c1                	mov    %eax,%ecx
  10151f:	eb 02                	jmp    101523 <strtol+0xdd>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  101521:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  101523:	85 f6                	test   %esi,%esi
  101525:	74 02                	je     101529 <strtol+0xe3>
		*endptr = (char *) s;
  101527:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  101529:	89 ca                	mov    %ecx,%edx
  10152b:	f7 da                	neg    %edx
  10152d:	85 ff                	test   %edi,%edi
  10152f:	0f 45 c2             	cmovne %edx,%eax
}
  101532:	5b                   	pop    %ebx
  101533:	5e                   	pop    %esi
  101534:	5f                   	pop    %edi
  101535:	5d                   	pop    %ebp
  101536:	c3                   	ret    
	...

00101540 <__udivdi3>:
  101540:	55                   	push   %ebp
  101541:	89 e5                	mov    %esp,%ebp
  101543:	57                   	push   %edi
  101544:	56                   	push   %esi
  101545:	8d 64 24 e0          	lea    -0x20(%esp),%esp
  101549:	8b 45 14             	mov    0x14(%ebp),%eax
  10154c:	8b 75 08             	mov    0x8(%ebp),%esi
  10154f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  101552:	85 c0                	test   %eax,%eax
  101554:	89 75 e8             	mov    %esi,-0x18(%ebp)
  101557:	8b 7d 0c             	mov    0xc(%ebp),%edi
  10155a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  10155d:	75 39                	jne    101598 <__udivdi3+0x58>
  10155f:	39 f9                	cmp    %edi,%ecx
  101561:	77 65                	ja     1015c8 <__udivdi3+0x88>
  101563:	85 c9                	test   %ecx,%ecx
  101565:	75 0b                	jne    101572 <__udivdi3+0x32>
  101567:	b8 01 00 00 00       	mov    $0x1,%eax
  10156c:	31 d2                	xor    %edx,%edx
  10156e:	f7 f1                	div    %ecx
  101570:	89 c1                	mov    %eax,%ecx
  101572:	89 f8                	mov    %edi,%eax
  101574:	31 d2                	xor    %edx,%edx
  101576:	f7 f1                	div    %ecx
  101578:	89 c7                	mov    %eax,%edi
  10157a:	89 f0                	mov    %esi,%eax
  10157c:	f7 f1                	div    %ecx
  10157e:	89 fa                	mov    %edi,%edx
  101580:	89 c6                	mov    %eax,%esi
  101582:	89 75 f0             	mov    %esi,-0x10(%ebp)
  101585:	89 55 f4             	mov    %edx,-0xc(%ebp)
  101588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10158b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10158e:	8d 64 24 20          	lea    0x20(%esp),%esp
  101592:	5e                   	pop    %esi
  101593:	5f                   	pop    %edi
  101594:	5d                   	pop    %ebp
  101595:	c3                   	ret    
  101596:	66 90                	xchg   %ax,%ax
  101598:	31 d2                	xor    %edx,%edx
  10159a:	31 f6                	xor    %esi,%esi
  10159c:	39 f8                	cmp    %edi,%eax
  10159e:	77 e2                	ja     101582 <__udivdi3+0x42>
  1015a0:	0f bd d0             	bsr    %eax,%edx
  1015a3:	83 f2 1f             	xor    $0x1f,%edx
  1015a6:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1015a9:	75 2d                	jne    1015d8 <__udivdi3+0x98>
  1015ab:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1015ae:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  1015b1:	76 06                	jbe    1015b9 <__udivdi3+0x79>
  1015b3:	39 f8                	cmp    %edi,%eax
  1015b5:	89 f2                	mov    %esi,%edx
  1015b7:	73 c9                	jae    101582 <__udivdi3+0x42>
  1015b9:	31 d2                	xor    %edx,%edx
  1015bb:	be 01 00 00 00       	mov    $0x1,%esi
  1015c0:	eb c0                	jmp    101582 <__udivdi3+0x42>
  1015c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1015c8:	89 f0                	mov    %esi,%eax
  1015ca:	89 fa                	mov    %edi,%edx
  1015cc:	f7 f1                	div    %ecx
  1015ce:	31 d2                	xor    %edx,%edx
  1015d0:	89 c6                	mov    %eax,%esi
  1015d2:	eb ae                	jmp    101582 <__udivdi3+0x42>
  1015d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1015d8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  1015dc:	89 c2                	mov    %eax,%edx
  1015de:	b8 20 00 00 00       	mov    $0x20,%eax
  1015e3:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1015e6:	d3 e2                	shl    %cl,%edx
  1015e8:	89 c1                	mov    %eax,%ecx
  1015ea:	8b 75 f0             	mov    -0x10(%ebp),%esi
  1015ed:	d3 ee                	shr    %cl,%esi
  1015ef:	09 d6                	or     %edx,%esi
  1015f1:	89 fa                	mov    %edi,%edx
  1015f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  1015f7:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  1015fa:	8b 75 f0             	mov    -0x10(%ebp),%esi
  1015fd:	d3 e6                	shl    %cl,%esi
  1015ff:	89 c1                	mov    %eax,%ecx
  101601:	89 75 f0             	mov    %esi,-0x10(%ebp)
  101604:	8b 75 e8             	mov    -0x18(%ebp),%esi
  101607:	d3 ea                	shr    %cl,%edx
  101609:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10160d:	d3 e7                	shl    %cl,%edi
  10160f:	89 c1                	mov    %eax,%ecx
  101611:	d3 ee                	shr    %cl,%esi
  101613:	09 fe                	or     %edi,%esi
  101615:	89 f0                	mov    %esi,%eax
  101617:	f7 75 e4             	divl   -0x1c(%ebp)
  10161a:	89 d7                	mov    %edx,%edi
  10161c:	89 c6                	mov    %eax,%esi
  10161e:	f7 65 f0             	mull   -0x10(%ebp)
  101621:	39 d7                	cmp    %edx,%edi
  101623:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  101626:	72 12                	jb     10163a <__udivdi3+0xfa>
  101628:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10162c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10162f:	d3 e2                	shl    %cl,%edx
  101631:	39 c2                	cmp    %eax,%edx
  101633:	73 08                	jae    10163d <__udivdi3+0xfd>
  101635:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  101638:	75 03                	jne    10163d <__udivdi3+0xfd>
  10163a:	8d 76 ff             	lea    -0x1(%esi),%esi
  10163d:	31 d2                	xor    %edx,%edx
  10163f:	e9 3e ff ff ff       	jmp    101582 <__udivdi3+0x42>
	...

00101650 <__umoddi3>:
  101650:	55                   	push   %ebp
  101651:	89 e5                	mov    %esp,%ebp
  101653:	57                   	push   %edi
  101654:	56                   	push   %esi
  101655:	8d 64 24 e0          	lea    -0x20(%esp),%esp
  101659:	8b 7d 14             	mov    0x14(%ebp),%edi
  10165c:	8b 45 08             	mov    0x8(%ebp),%eax
  10165f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  101662:	8b 75 0c             	mov    0xc(%ebp),%esi
  101665:	85 ff                	test   %edi,%edi
  101667:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10166a:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  10166d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  101670:	89 f2                	mov    %esi,%edx
  101672:	75 14                	jne    101688 <__umoddi3+0x38>
  101674:	39 f1                	cmp    %esi,%ecx
  101676:	76 40                	jbe    1016b8 <__umoddi3+0x68>
  101678:	f7 f1                	div    %ecx
  10167a:	89 d0                	mov    %edx,%eax
  10167c:	31 d2                	xor    %edx,%edx
  10167e:	8d 64 24 20          	lea    0x20(%esp),%esp
  101682:	5e                   	pop    %esi
  101683:	5f                   	pop    %edi
  101684:	5d                   	pop    %ebp
  101685:	c3                   	ret    
  101686:	66 90                	xchg   %ax,%ax
  101688:	39 f7                	cmp    %esi,%edi
  10168a:	77 4c                	ja     1016d8 <__umoddi3+0x88>
  10168c:	0f bd c7             	bsr    %edi,%eax
  10168f:	83 f0 1f             	xor    $0x1f,%eax
  101692:	89 45 ec             	mov    %eax,-0x14(%ebp)
  101695:	75 51                	jne    1016e8 <__umoddi3+0x98>
  101697:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  10169a:	0f 87 e8 00 00 00    	ja     101788 <__umoddi3+0x138>
  1016a0:	89 f2                	mov    %esi,%edx
  1016a2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  1016a5:	29 ce                	sub    %ecx,%esi
  1016a7:	19 fa                	sbb    %edi,%edx
  1016a9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  1016ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016af:	8d 64 24 20          	lea    0x20(%esp),%esp
  1016b3:	5e                   	pop    %esi
  1016b4:	5f                   	pop    %edi
  1016b5:	5d                   	pop    %ebp
  1016b6:	c3                   	ret    
  1016b7:	90                   	nop
  1016b8:	85 c9                	test   %ecx,%ecx
  1016ba:	75 0b                	jne    1016c7 <__umoddi3+0x77>
  1016bc:	b8 01 00 00 00       	mov    $0x1,%eax
  1016c1:	31 d2                	xor    %edx,%edx
  1016c3:	f7 f1                	div    %ecx
  1016c5:	89 c1                	mov    %eax,%ecx
  1016c7:	89 f0                	mov    %esi,%eax
  1016c9:	31 d2                	xor    %edx,%edx
  1016cb:	f7 f1                	div    %ecx
  1016cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016d0:	f7 f1                	div    %ecx
  1016d2:	eb a6                	jmp    10167a <__umoddi3+0x2a>
  1016d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1016d8:	89 f2                	mov    %esi,%edx
  1016da:	8d 64 24 20          	lea    0x20(%esp),%esp
  1016de:	5e                   	pop    %esi
  1016df:	5f                   	pop    %edi
  1016e0:	5d                   	pop    %ebp
  1016e1:	c3                   	ret    
  1016e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1016e8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  1016ec:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  1016f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016f6:	29 45 f0             	sub    %eax,-0x10(%ebp)
  1016f9:	d3 e7                	shl    %cl,%edi
  1016fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016fe:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  101702:	89 f2                	mov    %esi,%edx
  101704:	d3 e8                	shr    %cl,%eax
  101706:	09 f8                	or     %edi,%eax
  101708:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10170c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101712:	d3 e0                	shl    %cl,%eax
  101714:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  101718:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10171b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10171e:	d3 ea                	shr    %cl,%edx
  101720:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  101724:	d3 e6                	shl    %cl,%esi
  101726:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  10172a:	d3 e8                	shr    %cl,%eax
  10172c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  101730:	09 f0                	or     %esi,%eax
  101732:	8b 75 e8             	mov    -0x18(%ebp),%esi
  101735:	d3 e6                	shl    %cl,%esi
  101737:	f7 75 e4             	divl   -0x1c(%ebp)
  10173a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  10173d:	89 d6                	mov    %edx,%esi
  10173f:	f7 65 f4             	mull   -0xc(%ebp)
  101742:	89 d7                	mov    %edx,%edi
  101744:	89 c2                	mov    %eax,%edx
  101746:	39 fe                	cmp    %edi,%esi
  101748:	89 f9                	mov    %edi,%ecx
  10174a:	72 30                	jb     10177c <__umoddi3+0x12c>
  10174c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10174f:	72 27                	jb     101778 <__umoddi3+0x128>
  101751:	8b 45 e8             	mov    -0x18(%ebp),%eax
  101754:	29 d0                	sub    %edx,%eax
  101756:	19 ce                	sbb    %ecx,%esi
  101758:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10175c:	89 f2                	mov    %esi,%edx
  10175e:	d3 e8                	shr    %cl,%eax
  101760:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  101764:	d3 e2                	shl    %cl,%edx
  101766:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10176a:	09 d0                	or     %edx,%eax
  10176c:	89 f2                	mov    %esi,%edx
  10176e:	d3 ea                	shr    %cl,%edx
  101770:	8d 64 24 20          	lea    0x20(%esp),%esp
  101774:	5e                   	pop    %esi
  101775:	5f                   	pop    %edi
  101776:	5d                   	pop    %ebp
  101777:	c3                   	ret    
  101778:	39 fe                	cmp    %edi,%esi
  10177a:	75 d5                	jne    101751 <__umoddi3+0x101>
  10177c:	89 f9                	mov    %edi,%ecx
  10177e:	89 c2                	mov    %eax,%edx
  101780:	2b 55 f4             	sub    -0xc(%ebp),%edx
  101783:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  101786:	eb c9                	jmp    101751 <__umoddi3+0x101>
  101788:	39 f7                	cmp    %esi,%edi
  10178a:	0f 82 10 ff ff ff    	jb     1016a0 <__umoddi3+0x50>
  101790:	e9 17 ff ff ff       	jmp    1016ac <__umoddi3+0x5c>
