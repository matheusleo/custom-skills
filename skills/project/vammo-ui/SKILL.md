---
name: vammo-ui
description: Complete API reference for @leopardaelectric/vammo-ui component library. Use when building UI, choosing components, or checking available props/variants. NEVER create custom UI primitives — always use vammo-ui components first.
---

# @leopardaelectric/vammo-ui Component Library

Complete API reference for the vammo-ui component library used in this project. Built on Radix UI primitives with TailwindCSS styling and CVA variants.

**Import pattern:**

```typescript
import { Button, Select, Dialog, Badge, ... } from '@leopardaelectric/vammo-ui';
```

## When to Use This Skill

- Building any UI that needs buttons, inputs, dialogs, selects, tables, or other primitives
- Checking what components/props are available before creating custom ones
- Looking up variant options (sizes, colors, states)
- Understanding component composition patterns (Dialog, Sheet, Tabs, etc.)

---

## Form Components

### Input

```typescript
type InputProps = Omit<React.ComponentProps<'input'>, 'step'> & {
  hasError?: boolean;
  errorMessage?: string | false;
};
```

**Supported types:** `text`, `email`, `password`, `number`, `quantity`, `search`, `file`

- `type="quantity"` renders +/- buttons for increment/decrement
- `type="number"` renders up/down arrow controls
- Error state: pass `hasError` and `errorMessage`

### InputAutocomplete

```typescript
type Option = { value: string; label: string };

type InputAutocompleteProps = Omit<
  InputProps,
  'value' | 'onChange' | 'onSelect'
> & {
  value?: string;
  onChange?: (value: string) => void;
  onSelect?: (value: string, option?: Option) => void;
  options: Option[];
  debounceDelay?: number; // default: 300
  emptyMessage?: string;
  hasError?: boolean;
  errorMessage?: string | false;
  isLoading?: boolean;
  isInsideModal?: boolean;
};
```

Debounced search input with popover dropdown. Set `isInsideModal` when rendered inside a Dialog/Sheet.

### Select

```typescript
type SelectOption<V = string | number> = { value: V; label: string };

type SelectProps<V extends string | number> = {
  value?: V;
  onChange?: (value: V, option?: SelectOption<V>) => void;
  defaultValue?: V;
  options: SelectOption<V>[];
  id?: string;
  placeholder?: string;
  searchPlaceholder?: string;
  emptyMessage?: string;
  isLoading?: boolean;
  disabled?: boolean;
  className?: string;
  renderOption?: (
    option: SelectOption<V>,
    isSelected: boolean
  ) => React.ReactNode;
  searchValue?: string;
  onSearchChange?: (value: string) => void;
  showSearch?: boolean;
  hideCheckmark?: boolean;
  hideChevron?: boolean;
  isInsideModal?: boolean;
  hasError?: boolean;
  errorMessage?: string | false;
};
```

Controlled & uncontrolled. Supports custom option rendering, searchable dropdown, error states.

### MultiSelect

```typescript
type MultiSelectDotColor =
  | 'grey'
  | 'blue'
  | 'green'
  | 'orange'
  | 'yellow'
  | 'red'
  | 'black'
  | 'purple'
  | 'teal'
  | 'rose'
  | 'sky';

type MultiSelectOption = {
  value: string | number;
  label: string;
  count?: number; // right-aligned count in the option row (filter variant)
  dotColor?: MultiSelectDotColor; // colored status dot before the label (filter variant)
  style?: { color: BadgeProps['variant'] };
};

type MultiSelectProps<T extends string | number> = {
  values?: T[];
  onChange?: (values: T[]) => void;
  defaultValues?: T[];
  options: MultiSelectOption[];
  placeholder?: string;
  searchPlaceholder?: string;
  emptyMessage?: string;
  isLoading?: boolean;
  disabled?: boolean;
  className?: string;
  isInsideModal?: boolean;
  id?: string;
  variant?: 'form' | 'filter'; // default: 'form'
  icon?: ReactNode; // filter trigger icon
  clearLabel?: string; // clear-selection footer (filter variant)
  hasError?: boolean;
  errorMessage?: string | false;
};
```

Multi-value select with badge tags. Click badge to remove. Max 5 visible tags with overflow count. Supports colored badges via `style.color`.

**Filter variant (>= 4.42.0):** `variant='filter'` renders a quick-filter pill trigger (icon + `placeholder` as label + selected-count badge + chevron) with a searchable checkbox list, per-option `count`, optional `dotColor` status dots, and a `clearLabel` footer. Use this for toolbar quick filters — never build local filter composites in maestro.

### Combobox

```typescript
type ComboboxOption = { value: string; label: string; disabled?: boolean };

type ComboboxProps = {
  options: ComboboxOption[];
  value?: string;
  onValueChange?: (value: string) => void;
  placeholder?: string;
  searchPlaceholder?: string;
  emptyMessage?: string;
  disabled?: boolean;
  className?: string;
};
```

Searchable single-select powered by cmdk command palette.

### DatePicker

```typescript
type DatePickerProps = {
  date?: Date;
  onDateChange?: (date: Date | undefined) => void;
  placeholder?: string;
  disabled?: boolean;
  className?: string;
  dateFormat?: string; // default: 'PPP'
};
```

### DateRangePicker

```typescript
type DateRange = { from?: Date; to?: Date };

type DateRangePickerProps = {
  dateRange?: DateRange;
  onDateRangeChange?: (dateRange: DateRange | undefined) => void;
  placeholder?: string;
  disabled?: boolean;
  className?: string;
  dateFormat?: string; // default: 'LLL dd, y'
  numberOfMonths?: number; // default: 2
};
```

### Label

Radix UI Label. Renders `<label>` with `font-bold`. Supports peer-disabled opacity.

### Checkbox

Radix UI Checkbox (h-4 w-4). Checked/unchecked/indeterminate states.

### Switch

Radix UI Switch (h-5 w-9). Thumb translates on check.

---

## Button & Indicators

### Button

```typescript
interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
  id?: string;
}
```

**Variants:**
| variant | description |
|---|---|
| `default` | Primary background |
| `destructive` | Red/danger |
| `outline` | Border only |
| `secondary` | Secondary background |
| `ghost` | Transparent, hover highlight |
| `link` | Underline on hover |
| `success` | Green/success |

**Sizes:** `default` (h-9 px-4 py-2), `sm`, `lg`, `icon` (h-9 w-9)

Use `asChild` for Slot composition (e.g., wrapping a `<Link>`).

### Badge

```typescript
interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}
```

**Variants:** `default`, `secondary`, `destructive`, `outline`, `black`, `grey`, `blue`, `green`, `red`, `yellow`, `brown`

Text: `text-xs font-semibold`, rounded corners.

### Alert

```typescript
type AlertProps = React.HTMLAttributes<HTMLDivElement> &
  VariantProps<typeof alertVariants> & { hideIcon?: boolean };
```

**Variants:** `info` (default, blue), `success`, `warning`, `destructive`, `muted`

Static banner with a leading variant icon (Info/CircleCheck/TriangleAlert/CircleX). Use for in-modal/in-page notes, e.g. edit banners. `hideIcon` removes the icon.

### Spinner

```typescript
interface SpinnerProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof spinnerVariants> {}
```

**Sizes:** `sm` (h-4 w-4), `md` (h-8 w-8), `lg` (h-12 w-12), `xl` (h-16 w-16)

---

## Display Components

### Card (Composite)

```typescript
Card; // Root container (rounded-xl border)
CardHeader; // flex flex-col space-y-1.5 p-6
CardTitle; // font-semibold leading-none tracking-tight
CardDescription; // text-sm text-muted-foreground
CardContent; // p-6 pt-0
CardFooter; // flex items-center p-6 pt-0
```

### Typography (Composite)

```typescript
(H1, H2, H3, H4); // Heading elements with tracking
P; // Paragraph (leading-7)
Blockquote; // border-l-2 italic
InlineCode; // bg-muted font-mono
Lead; // text-xl text-muted-foreground
Large; // text-lg font-semibold
Small; // text-sm font-medium
Muted; // text-sm text-muted-foreground
List; // list-disc with spacing
```

All accept `{ children: React.ReactNode; className?: string }`.

### Avatar (Composite)

```typescript
Avatar; // h-10 w-10 rounded-full
AvatarImage; // aspect-square h-full w-full
AvatarFallback; // bg-primary-bg rounded-full
```

### Breadcrumb (Composite)

```typescript
Breadcrumb; // nav[aria-label="breadcrumb"]
BreadcrumbList; // ol flex flex-wrap gap-1.5
BreadcrumbItem; // li inline-flex gap-1.5
BreadcrumbLink; // a (asChild support)
BreadcrumbPage; // span[aria-current="page"]
BreadcrumbSeparator; // ChevronRight icon
BreadcrumbEllipsis; // MoreHorizontal icon
```

### Skeleton

```typescript
// div with bg-secondary-bg animate-pulse rounded-md
// Pass className for width/height
```

### Separator

```typescript
// Radix UI Separator
// orientation: 'horizontal' | 'vertical'
// decorative?: boolean (default: true)
```

---

## Dialog & Overlay Components

### Dialog (Custom Wrapper — primary usage)

```typescript
type DialogSize =
  | 'xs'
  | 'sm'
  | 'md'
  | 'lg'
  | 'xl'
  | '2xl'
  | '3xl'
  | '4xl'
  | '5xl'
  | '6xl'
  | '7xl'
  | 'full'
  | 'screen-sm'
  | 'screen-md'
  | 'screen-lg'
  | 'screen-xl'
  | 'screen-2xl';

interface DialogProps {
  header?: ReactNode;
  body: ReactNode;
  footer?: ReactNode;
  trigger?: ReactNode;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
  onSubmit?: (e: FormEvent<HTMLFormElement>) => void;
  size?: DialogSize;
  hideX?: boolean;
  isForm?: boolean;
}
```

Layout: header → divider → body (scrollable) → divider → footer. Set `isForm` + `onSubmit` for form dialogs.

### UnsavedChangesDialog

```typescript
type UnsavedChangesDialogProps = {
  isOpen: boolean;
  title: string;
  message: string;
  cancelLabel: string;
  discardLabel: string;
  onCancel: () => void;
  onDiscard: () => void;
};
```

### Dialog (Radix Primitive — for custom compositions)

```typescript
(Dialog,
  DialogTrigger,
  DialogPortal,
  DialogOverlay,
  DialogContent,
  DialogHeader,
  DialogFooter,
  DialogTitle,
  DialogDescription,
  DialogClose);
```

`DialogContent` accepts `hideCloseButton?: boolean`.

### Sheet

```typescript
(Sheet,
  SheetTrigger,
  SheetClose,
  SheetContent,
  SheetHeader,
  SheetFooter,
  SheetTitle,
  SheetDescription);
```

`SheetContent` props: `side?: 'top' | 'right' | 'bottom' | 'left'` (default: `'right'`). Slide animation per side. 75% width, max 24rem.

### Popover

```typescript
(Popover, PopoverTrigger, PopoverContent, PopoverAnchor);
```

`PopoverContent` props: `align?: 'start' | 'center' | 'end'`, `sideOffset?: number`, `isInsideModal?: boolean`. Width: w-72.

### Tooltip

```typescript
(Tooltip, TooltipTrigger, TooltipContent, TooltipProvider);
```

`TooltipProvider` has `delayDuration: 0`. Content: bg-primary with arrow.

---

## Navigation Components

### Tabs (High-level)

```typescript
type TabItem = {
  value: string;
  label: React.ReactNode;
  children?: React.ReactNode;
  disabled?: boolean;
  disabledText?: string; // tooltip on disabled
  className?: string;
};

interface TabsProps
  extends React.ComponentPropsWithoutRef<typeof TabsPrimitive.Root> {
  items?: TabItem[];
}
```

Auto-sets defaultValue. Grid layout on mobile. Tooltip for disabled items.

### Tabs (Raw Radix)

```typescript
(Tabs, TabsList, TabsTrigger, TabsContent);
```

For custom tab layouts when the high-level `Tabs` doesn't fit.

### ChromeTabs (Advanced)

```typescript
interface ChromeTabsProps {
  initialTabs?: ChromeTabDefinition[];
  initialActiveTabId?: ChromeTabId;
  onActiveTabChange?: (tabId: ChromeTabId) => void;
  className?: string;
  newTabLabel?: string;
  onCreateTab?: () => ChromeTabDefinition;
  onTabError?: (tabId: ChromeTabId, error: Error) => void;
  renderTabLabel?: (tab: ChromeTabInstance) => string;
  slots?: ChromeTabsSlots;
  labels?: ChromeTabsLabels;
  keepMounted?: boolean;
}
```

Browser-style tabs with drag-and-drop reorder, keyboard navigation (arrows, Home, End, Delete), error boundaries, loading states. Exposes imperative ref: `addTab`, `closeTab`, `setActiveTab`, `resetTab`, `reorderTabs`, `getTabs`.

### NavBar

```typescript
type NavMainItem = {
  title: string;
  url: string;
  icon?: React.ReactNode;
  badge?: string | number;
  isActive?: boolean;
  items?: NavMainSubItem[];
};

type NavMainSubItem = { title: string; url: string; isActive?: boolean };
type TLogo = { icon: React.ReactNode; label: string };
type TUser = {
  name: string;
  email: string;
  avatar: string;
  onLogout: () => void;
};

interface NavBarProps {
  items: NavMainItem[];
  logo?: TLogo;
  user?: TUser;
  RedirectComponent?: React.ElementType;
  collapsible?: 'offcanvas' | 'icon' | 'none';
  defaultOpen?: boolean;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
  onLogoClick?: () => void;
  className?: string;
  children?: React.ReactNode;
}
```

Sidebar-based navigation with logo, main items (with sub-items), and user footer with logout.

---

## Menu Components

### DropdownMenu (Radix Composite)

```typescript
(DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuCheckboxItem,
  DropdownMenuRadioItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  DropdownMenuGroup,
  DropdownMenuPortal,
  DropdownMenuSub,
  DropdownMenuSubContent,
  DropdownMenuSubTrigger,
  DropdownMenuRadioGroup);
```

`DropdownMenuItem` supports `inset?: boolean` for left padding alignment.

---

## Table Components

### Table (Raw HTML)

```typescript
(Table,
  TableHeader,
  TableBody,
  TableFooter,
  TableRow,
  TableHead,
  TableCell,
  TableCaption);
```

Basic styled HTML table. Use for simple tables.

### TableRaw (Advanced — TanStack React Table)

```typescript
type TableColumnType = 'text' | 'number' | 'date' | 'select' | 'custom';

type TableColumn = {
  id: string;
  type: TableColumnType;
  label: string;
  width?: string;
  sortable?: boolean;
  filterable?: boolean;
};

type RowAction = {
  label: string;
  icon?: React.ReactNode;
  onClick: (row: Row<TData>) => void;
};

type RowActionsConfig = {
  position?: 'start' | 'end';
  actions: RowAction[];
};
```

Full-featured data table with sorting, filtering, pagination, row actions, column visibility, and global search.

**Supporting components:** `TablePagination`, `GlobalSearcher`, `ColumnVisibility`, `TableConfigs`

**Hook:** `useTableInstance(params)` — returns table instance with sorting, filtering, pagination state.

### Pagination (UI)

```typescript
(Pagination,
  PaginationContent,
  PaginationItem,
  PaginationLink,
  PaginationPrevious,
  PaginationNext,
  PaginationEllipsis);
```

`PaginationLink` accepts `isActive?: boolean`.

---

## Layout Components

### Sidebar (Full Radix-based system)

```typescript
(SidebarProvider,
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupLabel,
  SidebarGroupAction,
  SidebarGroupContent,
  SidebarMenu,
  SidebarMenuItem,
  SidebarMenuButton,
  SidebarMenuAction,
  SidebarMenuBadge,
  SidebarMenuSkeleton,
  SidebarMenuSub,
  SidebarMenuSubItem,
  SidebarMenuSubButton,
  SidebarInput,
  SidebarSeparator,
  SidebarTrigger,
  SidebarInset,
  SidebarRail,
  useSidebar);
```

Context-based state with cookie persistence. Mobile-responsive (Sheet on mobile). Keyboard shortcut: Ctrl/Cmd+B. Variants: `sidebar`, `floating`, `inset`. Collapsible: `offcanvas`, `icon`, `none`.

### ScrollArea

```typescript
(ScrollArea, ScrollBar);
```

`ScrollBar` props: `orientation?: 'vertical' | 'horizontal'`. Auto-hiding scrollbars.

### Command (Palette)

```typescript
(Command,
  CommandDialog,
  CommandInput,
  CommandList,
  CommandEmpty,
  CommandGroup,
  CommandItem,
  CommandShortcut,
  CommandSeparator);
```

cmdk-powered command palette. `CommandList` max-h: 300px.

### Calendar

```typescript
(Calendar, CalendarDayButton);
```

react-day-picker wrapper. `mode: 'single' | 'range'`. Multi-month display support.

### Collapsible

```typescript
(Collapsible, CollapsibleTrigger, CollapsibleContent);
```

Radix Collapsible primitive.

---

## Key Patterns

### isInsideModal

Components with popover-based dropdowns (`Select`, `MultiSelect`, `InputAutocomplete`, `PopoverContent`) accept `isInsideModal?: boolean`. Set this to `true` when the component is rendered inside a Dialog or Sheet — it renders the popover without a Portal to avoid z-index issues.

### Error States

Form components (`Input`, `Select`, `MultiSelect`, `InputAutocomplete`) support:

```typescript
hasError?: boolean;
errorMessage?: string | false;
```

### Styling

All components use `cn()` (clsx + tailwind-merge) for class composition. Override styles via `className` prop.
