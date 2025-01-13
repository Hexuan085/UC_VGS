import numpy as np
import matplotlib.pyplot as plt

# 设置每个热力圆的半径
radii = [0.25, 0.5, 0.75, 1]  # 四个圆环
total = [46*2, 186*2, 411*2, 597*2, 2896*2]
# 定义每个热力圆对应的不同数据（数值越大，颜色越深）
data_groups = [
    [46*2-71, 46*2-66, 46*2-61, 46*2-55],  # 对应39-bus
    [186*2-342, 186*2-337, 186*2-331, 186*2-327],  # 对应118-bus
   [411*2-783, 411*2-779, 411*2-772, 411*2-769],  # 对应300-bus
    [597*2-1154, 597*2-1149, 597*2-1144, 597*2-1137],  # 对应500-bus
    [2896*2-4536, 2896*2-4524, 2896*2-4516, 2896*2-4507]  # 对应2383-bus
]

center = [46*2-76, 186*2-345, 411*2-790, 597*2-1158, 2896*2-4546]
# 不同圆环颜色
colors = ['black', 'black', 'red', 'red']  # 自定义颜色列表

# x轴标签
x_labels = ['39-bus', '118-bus', '300-bus', '500-bus', '2383-bus']

# 创建图形和子图
fig, axs = plt.subplots(1, 5, figsize=(15, 5))
i = 0
left = 0
# 绘制每个热力圆
for ax, x_label, values in zip(axs, x_labels, data_groups):
    for radius, value, color in sorted(zip(radii, values,colors), key=lambda x: x[0], reverse=True):
        color_intensity = value / 70  # 从0到1
        colora = plt.cm.Blues(color_intensity)  # 数值越大，颜色越深
        circle = plt.Circle((0, 0), radius, color=colora, ec="black", lw=1.5, alpha=0.8)
        ax.add_artist(circle)

        # 在圆环的正左方顶点标出数据标签
        if left == 0:
            ax.text(-radius, 0, str(value), ha='center', va='center', fontsize=10, color=color)
            left = 1
        else:
            ax.text(0, radius, str(value), ha='center', va='center', fontsize=10, color=color)
            left = 0
    # 在圆心标出数据标签
    ax.text(0, 0, str(center[i]), ha='center', va='center', fontsize=10, color=colors[2])
    i = i+1
    # 设置坐标轴范围
    ax.set_xlim(-1, 1)
    ax.set_ylim(-1, 1)

    # 设置坐标轴比例为相等
    ax.set_aspect('equal')

    # 设置坐标轴原点在圆心
    ax.axhline(0, color='black', lw=0.8)
    ax.axvline(0, color='black', lw=0.8)

    # 设置刻度
    ax.set_xticks(np.arange(-1, 1, 0.5))
    ax.set_yticks(np.arange(-1, 1, 0.5))

    # 设置 x 轴标签
    ax.set_xlabel(x_label)
axs[0].set_ylabel('Load Variation Range')

# 设置整体标题
# plt.suptitle("Heatmap Circles with Different Colors and Matching Labels", fontsize=16, y=1.05)

# 显示图形
plt.tight_layout(rect=[0, 0, 1, 0.95])  # 调整布局以防标题被遮挡
plt.show()
