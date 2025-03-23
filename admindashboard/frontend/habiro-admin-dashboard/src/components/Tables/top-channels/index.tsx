import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { compactFormat, standardFormat } from "@/lib/format-number";
import { cn } from "@/lib/utils";
import Image from "next/image";
import { getTopChannels } from "../fetch";

export async function TopChannels({ className }: { className?: string }) {
  const data = await getTopChannels();

  return (
    <div
  className={cn(
    "w-full max-w-4xl min-h-[350px] rounded-lg bg-white px-5 pb-3 pt-5 shadow-md dark:bg-gray-dark dark:shadow-lg",
    className
  )}
>
  <h2 className="mb-3 text-lg font-semibold text-dark dark:text-white">
    Top Channels
  </h2>

  <div className="overflow-x-auto"> 
    <Table className="w-full">
      <TableHeader>
        <TableRow className="border-none uppercase [&>th]:text-center text-sm">
          <TableHead className="min-w-[130px] !text-left px-3">Platform</TableHead>
          <TableHead className="px-3">Users</TableHead>
          <TableHead className="!text-right px-3">Earnings</TableHead>
          <TableHead className="px-3">Orders</TableHead>
          <TableHead className="px-3">Success Rate</TableHead>
        </TableRow>
      </TableHeader>

      <TableBody>
        {data.map((channel, i) => (
          <TableRow
            className="h-10 text-center text-sm font-medium text-dark dark:text-white" // Adjust row height & font size
            key={channel.name + i}
          >
            <TableCell className="flex min-w-fit items-center gap-2 p-2">
              <Image
                src={channel.logo}
                className="size-6 rounded-full object-cover"
                width={32}
                height={32}
                alt={channel.name + ' Logo'}
                role="presentation"
              />
              <div className="text-sm">{channel.name}</div>
            </TableCell>

            <TableCell className="p-2">{compactFormat(channel.visitors)}</TableCell>

            <TableCell className="!text-right p-2 text-green-light-1">
              ${standardFormat(channel.revenues)}
            </TableCell>

            <TableCell className="p-2">{channel.sales}</TableCell>

            <TableCell className="p-2">{channel.conversion}%</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  </div>
</div>


  );
}
